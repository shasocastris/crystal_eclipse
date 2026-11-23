"""Python harness over SameBoy (via libsbshim.so) for Crystal Eclipse regression tests.

Not committed: a helper, listed in docs/helper_scripts.md.
"""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import ctypes
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SAMEBOY = os.environ.get('SAMEBOY', f'{_ROMHACKS}/SameBoy')
BOOT = os.path.join(SAMEBOY, 'build/bin/tester/cgb_boot.bin')
REPO = os.environ.get('CE_REPO') or os.path.abspath(os.path.join(HERE, '../../..'))

_lib = ctypes.CDLL(os.path.join(HERE, 'libsbshim.so'))
_P = ctypes.c_void_p
for name, res, args in [
    ('sb_new', _P, [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p]),
    ('sb_free', None, [_P]),
    ('sb_render', None, [_P, ctypes.c_int]),
    ('sb_pixels', ctypes.POINTER(ctypes.c_uint32), [_P]),
    ('sb_frame_count', ctypes.c_uint64, [_P]),
    ('sb_key', None, [_P, ctypes.c_int, ctypes.c_int]),
    ('sb_frames', None, [_P, ctypes.c_int]),
    ('sb_run_until', ctypes.c_int, [_P, ctypes.c_int, ctypes.c_int, ctypes.c_int]),
    ('sb_run_until_any', ctypes.c_int, [_P, ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int), ctypes.c_int, ctypes.c_int]),
    ('sb_step', None, [_P]),
    ('sb_read', ctypes.c_uint8, [_P, ctypes.c_int]),
    ('sb_write', None, [_P, ctypes.c_int, ctypes.c_int]),
    ('sb_read_wram', ctypes.c_uint8, [_P, ctypes.c_int, ctypes.c_int]),
    ('sb_write_wram', None, [_P, ctypes.c_int, ctypes.c_int, ctypes.c_int]),
    ('sb_read_sram', ctypes.c_uint8, [_P, ctypes.c_int, ctypes.c_int]),
    ('sb_rom_bank', ctypes.c_int, [_P]),
    ('sb_reg', ctypes.c_int, [_P, ctypes.c_int]),
    ('sb_set_reg', None, [_P, ctypes.c_int, ctypes.c_int]),
    ('sb_state_size', ctypes.c_size_t, [_P]),
    ('sb_save_state', None, [_P, ctypes.c_char_p]),
    ('sb_load_state', ctypes.c_int, [_P, ctypes.c_char_p, ctypes.c_size_t]),
    ('sb_save_battery', ctypes.c_int, [_P, ctypes.c_char_p]),
]:
    f = getattr(_lib, name)
    f.restype, f.argtypes = res, args

KEYS = {'right': 0, 'left': 1, 'up': 2, 'down': 3, 'a': 4, 'b': 5, 'select': 6, 'start': 7}
REGS = {'af': 0, 'bc': 1, 'de': 2, 'hl': 3, 'sp': 4, 'pc': 5}


def load_sym(path):
    """label -> (bank, addr). Local labels keep their full Parent.local name."""
    syms = {}
    with open(path) as f:
        for line in f:
            if not line or line[0] == ';':
                continue
            loc, _, name = line.strip().partition(' ')
            if ':' not in loc:
                continue
            b, a = loc.split(':')
            syms.setdefault(name, (int(b, 16), int(a, 16)))
    return syms


class Game:
    def __init__(self, rom=None, sym=None, battery=None, render=False):
        rom = rom or os.path.join(REPO, 'crystal_eclipse_debug.gbc')
        sym = sym or os.path.splitext(rom)[0] + '.sym'
        self.rom, self.syms = rom, load_sym(sym)
        self.h = _lib.sb_new(BOOT.encode(), rom.encode(), (battery or '').encode())
        if not self.h:
            raise RuntimeError('SameBoy failed to load %s' % rom)
        self.render(render)

    def close(self):
        if self.h:
            _lib.sb_free(self.h)
            self.h = None

    def __enter__(self):
        return self

    def __exit__(self, *a):
        self.close()

    # --- time and input ---
    def render(self, on):
        _lib.sb_render(self.h, int(bool(on)))

    @property
    def frame(self):
        return _lib.sb_frame_count(self.h)

    def frames(self, n=1):
        _lib.sb_frames(self.h, n)

    def press(self, key, hold=4, after=8):
        for k in key.split('+'):
            _lib.sb_key(self.h, KEYS[k], 1)
        self.frames(hold)
        for k in key.split('+'):
            _lib.sb_key(self.h, KEYS[k], 0)
        self.frames(after)

    def hold(self, key, on=True):
        _lib.sb_key(self.h, KEYS[key], int(on))

    # --- symbols and memory ---
    def addr(self, label):
        if isinstance(label, tuple):
            return label
        if isinstance(label, int):
            return (-1, label)  # raw address: use the bus (current banks)
        base, plus, off = label.partition('+')
        b, a = self.syms[base]
        return (b, a + (int(off, 0) if plus else 0))

    def read(self, label, n=None):
        b, a = self.addr(label)
        out = []
        for i in range(n or 1):
            x = a + i
            if b < 0:
                out.append(_lib.sb_read(self.h, x))
            elif 0xc000 <= x < 0xe000:
                out.append(_lib.sb_read_wram(self.h, b, x))
            elif 0xa000 <= x < 0xc000:
                out.append(_lib.sb_read_sram(self.h, b, x))
            else:
                out.append(_lib.sb_read(self.h, x))
        return out if n else out[0]

    def read16(self, label, big=True):
        lo_hi = self.read(label, 2)
        return (lo_hi[0] << 8 | lo_hi[1]) if big else (lo_hi[1] << 8 | lo_hi[0])

    def write(self, label, data):
        b, a = self.addr(label)
        if isinstance(data, int):
            data = [data]
        for i, v in enumerate(data):
            x = a + i
            if b >= 0 and 0xc000 <= x < 0xe000:
                _lib.sb_write_wram(self.h, b, x, v)
            else:
                _lib.sb_write(self.h, x, v)

    def reg(self, name):
        return _lib.sb_reg(self.h, REGS[name])

    def set_reg(self, name, v):
        _lib.sb_set_reg(self.h, REGS[name], v)

    @property
    def rom_bank(self):
        return _lib.sb_rom_bank(self.h)

    # --- execution control ---
    def run_until(self, label, max_frames=600):
        """Run until PC is at label (right before it executes). Returns True on hit."""
        b, a = self.addr(label)
        return bool(_lib.sb_run_until(self.h, b if a >= 0x4000 else -1, a, max_frames))

    def run_until_any(self, labels, max_frames=600):
        """Run until PC is at any of `labels`. Returns the label hit, or None."""
        locs = [self.addr(l) for l in labels]
        n = len(locs)
        banks = (ctypes.c_int * n)(*[b if a >= 0x4000 else -1 for b, a in locs])
        addrs = (ctypes.c_int * n)(*[a for b, a in locs])
        i = _lib.sb_run_until_any(self.h, banks, addrs, n, max_frames)
        return labels[i] if i >= 0 else None

    def call(self, label, a=0, bc=None, de=None, hl=0, f=0, max_frames=600):
        """Call a routine from a paused point (best: PlayerEvents in the overworld) and run until it
        returns there. Goes through the game's FarCall_hl, so the callee sees a/hl as given and the
        ROM bank is restored afterwards. Returns the callee's registers {'a','f','bc','de','hl'}."""
        bank, target = self.addr(label)
        ret_pc, sp = self.reg('pc'), self.reg('sp')
        ret_bank = self.rom_bank
        self.write('hFarCallSavedA', a)
        self.write('hFarCallSavedL', hl & 0xff)
        self.write('hFarCallSavedH', hl >> 8)
        if bc is not None:
            self.set_reg('bc', bc)
        if de is not None:
            self.set_reg('de', de)
        self.set_reg('af', bank << 8 | (f & 0xf0))
        self.set_reg('hl', target)
        sp -= 2
        self.write(sp, ret_pc & 0xff)
        self.write(sp + 1, ret_pc >> 8)
        self.set_reg('sp', sp)
        self.set_reg('pc', self.syms['FarCall_hl'][1])
        # stop at the return address with the stack unwound
        for _ in range(64):
            if not _lib.sb_run_until(self.h, ret_bank if ret_pc >= 0x4000 else -1, ret_pc, max_frames):
                raise TimeoutError('%s did not return within %d frames' % (label, max_frames))
            if self.reg('sp') == sp + 2:
                break
            _lib.sb_step(self.h)  # same pc reached deeper in the stack; move past it
        else:
            raise RuntimeError('%s: return address kept being hit with the wrong stack' % label)
        af = self.reg('af')
        return {'a': af >> 8, 'f': af & 0xff, 'bc': self.reg('bc'), 'de': self.reg('de'), 'hl': self.reg('hl'),
                'carry': bool(af & 0x10), 'zero': bool(af & 0x80)}

    def state(self):
        buf = ctypes.create_string_buffer(_lib.sb_state_size(self.h))
        _lib.sb_save_state(self.h, buf)
        return buf.raw

    def load(self, state):
        if _lib.sb_load_state(self.h, state, len(state)):
            raise RuntimeError('state load failed')

    def save_battery(self, path):
        return _lib.sb_save_battery(self.h, path.encode())

    # --- screen ---
    def screenshot(self, path=None):
        from PIL import Image
        px = _lib.sb_pixels(self.h)
        img = Image.new('RGB', (160, 144))
        img.putdata([((p >> 16) & 255, (p >> 8) & 255, p & 255) for p in px[:160 * 144]])
        if path:
            img.save(path)
        return img
