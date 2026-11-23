// Thin C bridge over SameBoy's core for the Python regression harness.
// Build: see build.sh. Not committed (helper code; see docs/helper_scripts.md).
#include <stdlib.h>
#include <string.h>
#include "gb.h"

typedef struct {
    GB_gameboy_t *gb;
    uint32_t px[160 * 144];
    uint64_t frames;
} sb_t;

static uint32_t enc(GB_gameboy_t *gb, uint8_t r, uint8_t g, uint8_t b) { return (uint32_t)r << 16 | g << 8 | b; }

static void on_vblank(GB_gameboy_t *gb, GB_vblank_type_t t)
{
    sb_t *s = GB_get_user_data(gb);
    s->frames++;
}

sb_t *sb_new(const char *boot, const char *rom, const char *battery)
{
    sb_t *s = calloc(1, sizeof(*s));
    s->gb = GB_init(GB_alloc(), GB_MODEL_CGB_E);
    GB_set_user_data(s->gb, s);
    GB_set_pixels_output(s->gb, s->px);
    GB_set_rgb_encode_callback(s->gb, enc);
    GB_set_vblank_callback(s->gb, on_vblank);
    GB_set_rtc_mode(s->gb, GB_RTC_MODE_ACCURATE);
    if (GB_load_boot_rom(s->gb, boot) || GB_load_rom(s->gb, rom)) { free(s); return NULL; }
    if (battery && *battery) GB_load_battery(s->gb, battery);
    GB_set_turbo_mode(s->gb, true, true);
    return s;
}

void sb_free(sb_t *s) { GB_free(s->gb); free(s); }
void sb_render(sb_t *s, int on) { GB_set_rendering_disabled(s->gb, !on); }
uint32_t *sb_pixels(sb_t *s) { return s->px; }
uint64_t sb_frame_count(sb_t *s) { return s->frames; }
void sb_key(sb_t *s, int key, int pressed) { GB_set_key_state(s->gb, key, pressed); }

void sb_frames(sb_t *s, int n)
{
    uint64_t target = s->frames + n;
    while (s->frames < target) GB_run(s->gb);
}

// Run until PC reaches bank:addr (bank -1 = any) or max_frames pass. Returns 1 on hit.
// Always executes at least one instruction, then stops right before executing the one at addr.
int sb_run_until(sb_t *s, int bank, int addr, int max_frames)
{
    uint64_t target = s->frames + max_frames;
    GB_registers_t *r = GB_get_registers(s->gb);
    do {
        GB_run(s->gb);
        if (r->pc == addr) {
            if (bank < 0 || addr < 0x4000 || addr >= 0x8000) return 1;
            uint16_t b;
            GB_get_direct_access(s->gb, GB_DIRECT_ACCESS_ROM, NULL, &b);
            if (b == bank) return 1;
        }
    } while (s->frames < target);
    return 0;
}

// Like sb_run_until for n targets at once. Returns the index hit, or -1.
int sb_run_until_any(sb_t *s, const int *banks, const int *addrs, int n, int max_frames)
{
    uint64_t target = s->frames + max_frames;
    GB_registers_t *r = GB_get_registers(s->gb);
    do {
        GB_run(s->gb);
        for (int i = 0; i < n; i++) {
            if (r->pc != addrs[i]) continue;
            if (banks[i] < 0 || addrs[i] < 0x4000 || addrs[i] >= 0x8000) return i;
            uint16_t b;
            GB_get_direct_access(s->gb, GB_DIRECT_ACCESS_ROM, NULL, &b);
            if (b == banks[i]) return i;
        }
    } while (s->frames < target);
    return -1;
}

void sb_step(sb_t *s) { GB_run(s->gb); }

uint8_t sb_read(sb_t *s, int addr) { return GB_safe_read_memory(s->gb, addr); }
void sb_write(sb_t *s, int addr, int v) { GB_write_memory(s->gb, addr, v); }

static uint8_t *wram_ptr(sb_t *s, int bank, int addr)
{
    size_t size; uint16_t cur;
    uint8_t *ram = GB_get_direct_access(s->gb, GB_DIRECT_ACCESS_RAM, &size, &cur);
    if (addr < 0xd000) return ram + (addr - 0xc000);
    if (bank <= 0) bank = 1;
    return ram + bank * 0x1000 + (addr - 0xd000);
}
uint8_t sb_read_wram(sb_t *s, int bank, int addr) { return *wram_ptr(s, bank, addr); }
void sb_write_wram(sb_t *s, int bank, int addr, int v) { *wram_ptr(s, bank, addr) = v; }

uint8_t sb_read_sram(sb_t *s, int bank, int addr)
{
    size_t size; uint16_t cur;
    uint8_t *ram = GB_get_direct_access(s->gb, GB_DIRECT_ACCESS_CART_RAM, &size, &cur);
    size_t off = bank * 0x2000 + (addr - 0xa000);
    return off < size ? ram[off] : 0xff;
}

int sb_rom_bank(sb_t *s)
{
    uint16_t bank;
    GB_get_direct_access(s->gb, GB_DIRECT_ACCESS_ROM, NULL, &bank);
    return bank;
}

// 0=AF 1=BC 2=DE 3=HL 4=SP 5=PC
int sb_reg(sb_t *s, int i) { return GB_get_registers(s->gb)->registers[i]; }
void sb_set_reg(sb_t *s, int i, int v) { GB_get_registers(s->gb)->registers[i] = v; }

size_t sb_state_size(sb_t *s) { return GB_get_save_state_size(s->gb); }
void sb_save_state(sb_t *s, uint8_t *buf) { GB_save_state_to_buffer(s->gb, buf); }
int sb_load_state(sb_t *s, const uint8_t *buf, size_t len) { return GB_load_state_from_buffer(s->gb, buf, len); }
int sb_save_battery(sb_t *s, const char *path) { return GB_save_battery(s->gb, path); }
