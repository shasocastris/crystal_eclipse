"""Crystal Eclipse helpers on top of gb.Game: flags, party fields, ROM data, ID conversion."""
from consts import resolve, value


def rom_byte(g, label, offset=0, n=1):
    """Read ROM bytes at a banked label straight from the .gbc file."""
    if not hasattr(g, '_rom'):
        with open(g.rom, 'rb') as f:
            g._rom = f.read()
    bank, addr = g.addr(label)
    base = addr + offset if addr < 0x4000 else bank * 0x4000 + (addr + offset - 0x4000)
    return list(g._rom[base:base + n])


# --- event and engine flags ---
def event(g, name):
    n = value(name)
    return bool(g.read('wEventFlags+%d' % (n // 8)) & (1 << (n % 8)))


def set_event(g, name, on=True):
    n = value(name)
    lab = 'wEventFlags+%d' % (n // 8)
    v = g.read(lab)
    g.write(lab, v | (1 << (n % 8)) if on else v & ~(1 << (n % 8)) & 0xff)


def _engine_loc(g, name):
    lo, hi, mask = rom_byte(g, 'EngineFlags', value(name) * 3, 3)
    return (1, hi << 8 | lo), mask


def engine(g, name):
    loc, mask = _engine_loc(g, name)
    return bool(g.read(loc) & mask)


def set_engine(g, name, on=True):
    loc, mask = _engine_loc(g, name)
    v = g.read(loc)
    g.write(loc, v | mask if on else v & ~mask & 0xff)


# --- party ---
def mon(g, slot, field):
    """Address label of a party mon field: slot 0-5, field like 'MON_DVS'."""
    v = resolve('PARTYMON_STRUCT_LENGTH', field)
    return 'wPartyMon1+%d' % (slot * v['PARTYMON_STRUCT_LENGTH'] + v[field])


def mon_read(g, slot, field, n=1):
    return g.read(mon(g, slot, field), n)


def mon_write(g, slot, field, data):
    g.write(mon(g, slot, field), data)


def mon_word(g, slot, field):
    return g.read16(mon(g, slot, field))


def species_index(g, slot):
    """16-bit species constant of party slot, via the game's own conversion."""
    rid = g.read('wPartySpecies+%d' % slot)
    return g.call('GetPokemonIndexFromID', a=rid)['hl']


def species_id(g, const_name):
    """Runtime 8-bit ID for a species constant (allocates a slot like the game would)."""
    return g.call('GetPokemonIDFromIndex', hl=value(const_name))['a']
