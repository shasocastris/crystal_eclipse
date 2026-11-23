"""Map blocks from a built ROM. Since branch 92 they are LZ-compressed; older ROMs store them raw."""


def lz_decompress(data):
    """This repo's LZ format (tools/lzcomp, home/decompress.asm)."""
    out = bytearray()
    i = 0
    while data[i] != 0xff:
        b = data[i]
        i += 1
        if b >> 5 == 7:  # long command: 10-bit length
            cmd, n = (b >> 2) & 7, ((b & 3) << 8 | data[i]) + 1
            i += 1
        else:
            cmd, n = b >> 5, (b & 0x1f) + 1
        n += {1: 1, 2: 2}.get(cmd, 0)  # CSE's lzcomp: repeat starts at 2, alternate at 3
        if cmd == 0:  # literal
            out += data[i:i + n]
            i += n
        elif cmd == 1:  # iterate one byte
            out += bytes([data[i]]) * n
            i += 1
        elif cmd == 2:  # alternate two bytes
            out += bytes(data[i + k % 2] for k in range(n))
            i += 2
        elif cmd == 3:  # zeros
            out += bytes(n)
        else:  # copy from earlier output: as is, bit-flipped, or backwards
            o = data[i]
            i += 1
            if o & 0x80:
                off = len(out) - (o & 0x7f) - 1
            else:
                off = o << 8 | data[i]
                i += 1
            for k in range(n):
                if cmd == 4:
                    out.append(out[off + k])
                elif cmd == 5:
                    out.append(int(f'{out[off + k]:08b}'[::-1], 2))
                else:
                    out.append(out[off - k])
    return bytes(out)


def map_blocks(rom, offset, size, syms):
    """`size` block bytes for the map whose <Map>_Blocks label is at file offset `offset`.
    A ROM that has DecompressMapBlocks stores them compressed."""
    if 'DecompressMapBlocks' in syms:
        return lz_decompress(rom[offset:offset + 0x2000])[:size]
    return rom[offset:offset + size]
