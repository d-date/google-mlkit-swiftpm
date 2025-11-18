#!/usr/bin/env python3
import sys
import struct
from pathlib import Path

# Константы из mach-o/loader.h
MH_MAGIC_64      = 0xfeedfacf

FAT_MAGIC        = 0xcafebabe
FAT_CIGAM        = 0xbebafeca  # byte-swapped FAT_MAGIC

CPU_TYPE_ARM64   = 0x0100000c
CPU_TYPE_X86_64  = 0x01000007

LC_DATA_IN_CODE          = 0x29
LC_VERSION_MIN_IPHONEOS  = 0x25

def encode_version(major: int, minor: int, patch: int = 0) -> int:
    return (major << 16) | (minor << 8) | patch

# Желаемые версии: iOS 15.5.0 и SDK 17.2.0
MIN_OS = encode_version(15, 5, 0)
SDK    = encode_version(17, 2, 0)

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <path-to-binary> [arch]", file=sys.stderr)
    print("  arch: arm64 (default) or x86_64", file=sys.stderr)
    sys.exit(1)

path = Path(sys.argv[1])

arch_name = sys.argv[2] if len(sys.argv) >= 3 else "arm64"
if arch_name == "arm64":
    desired_cputype = CPU_TYPE_ARM64
elif arch_name == "x86_64":
    desired_cputype = CPU_TYPE_X86_64
else:
    print(f"Unknown arch '{arch_name}', use 'arm64' or 'x86_64'", file=sys.stderr)
    sys.exit(1)

data = bytearray(path.read_bytes())

# --- Шаг 1. Разбор возможного FAT-заголовка ---
# FAT-заголовок — всегда big-endian
magic_be, = struct.unpack_from(">I", data, 0)

if magic_be in (FAT_MAGIC, FAT_CIGAM):
    # struct fat_header { uint32_t magic; uint32_t nfat_arch; }
    nfat_arch, = struct.unpack_from(">I", data, 4)

    arch_offset = None
    arch_size = None

    for i in range(nfat_arch):
        # struct fat_arch {
        #   uint32_t cputype, cpusubtype, offset, size, align;
        # }
        base = 8 + i * 20
        cputype, cpusubtype, offset, size, align = struct.unpack_from(">IIIII", data, base)
        if cputype == desired_cputype:
            arch_offset = offset
            arch_size = size
            print(f"Found slice arch={arch_name} at offset {arch_offset}, size {arch_size}")
            break

    if arch_offset is None:
        raise RuntimeError(f"Slice with arch={arch_name} not found in FAT binary")

    macho_base = arch_offset
else:
    # Не FAT, сразу обычный Mach-O
    macho_base = 0

# --- Шаг 2. Читаем mach_header_64 внутри выбранного слайса ---
# struct mach_header_64 {
#   uint32_t magic;
#   int32_t  cputype;
#   int32_t  cpusubtype;
#   uint32_t filetype;
#   uint32_t ncmds;
#   uint32_t sizeofcmds;
#   uint32_t flags;
#   uint32_t reserved;
# };

hdr_off = macho_base
magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, reserved = \
    struct.unpack_from("<IiiIIIII", data, hdr_off)

if magic != MH_MAGIC_64:
    raise RuntimeError(f"Unexpected Mach-O magic in slice: 0x{magic:08x} (ожидали MH_MAGIC_64)")

print(f"Mach-O slice: ncmds={ncmds}, sizeofcmds={sizeofcmds}, cputype=0x{cputype:08x}")

# --- Шаг 3. Ищем LC_DATA_IN_CODE и патчим в LC_VERSION_MIN_IPHONEOS ---

offset = hdr_off + 32  # размер mach_header_64
patched = False

for i in range(ncmds):
    cmd, cmdsize = struct.unpack_from("<II", data, offset)

    if cmd == LC_DATA_IN_CODE and cmdsize == 16:
        print(f"Found LC_DATA_IN_CODE at load command #{i}, file offset {offset}")

        # Меняем тип команды
        struct.pack_into("<I", data, offset, LC_VERSION_MIN_IPHONEOS)
        # cmdsize оставляем 16
        # Записываем version и sdk
        struct.pack_into("<II", data, offset + 8, MIN_OS, SDK)

        patched = True
        print(f"Patched to LC_VERSION_MIN_IPHONEOS (minOS 15.5.0, sdk 17.2.0)")
        break

    offset += cmdsize

if not patched:
    raise RuntimeError("LC_DATA_IN_CODE (cmd=0x29, cmdsize=16) не найден — нечего патчить")

path.write_bytes(data)
print("Done. Проверьте результат через xcrun otool -l <file>.")