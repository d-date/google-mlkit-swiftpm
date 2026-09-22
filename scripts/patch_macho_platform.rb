#!/usr/bin/env ruby
# frozen_string_literal: true

# Rewrites the `platform` field of every LC_BUILD_VERSION load command in a
# thin Mach-O file or a thin `ar` archive, in place.
#
# Used to turn the device-arm64 slice of a pre-built ML Kit framework into an
# arm64 iOS Simulator slice: the Mach-O code is identical, only the platform
# the linker checks differs. Patching in place (rather than extracting members,
# running `vtool` on each and repacking with `libtool`) keeps the archive's
# member layout and symbol index untouched -- ML Kit archives contain
# duplicate member names (e.g. three `globals.o` in MLKitCommon) that cannot
# survive an extract/repack round trip.
#
# Usage: patch_macho_platform.rb <file> <platform-number>
#        platform 2 = PLATFORM_IOS, 7 = PLATFORM_IOSSIMULATOR

# Raised when a file declares no platform at all. A Mach-O object file has no
# spare room between its load commands and its first section, so the command
# cannot be added in place -- the caller has to relink instead.
class NoBuildVersionError < StandardError; end

AR_MAGIC = "!<arch>\n"
AR_HEADER_SIZE = 60
MH_MAGIC_64 = 0xfeedfacf
MH_CIGAM_64 = 0xcffaedfe
MH_MAGIC_32 = 0xfeedface
MH_CIGAM_32 = 0xcefaedfe
LC_BUILD_VERSION = 0x32

# Patches every LC_BUILD_VERSION at `base` (offset of the Mach-O header in
# `data`). Returns the number of load commands rewritten.
def patch_macho(data, base, platform)
  magic = data[base, 4].unpack1("V")
  case magic
  when MH_MAGIC_64 then header_size = 32
  when MH_MAGIC_32 then header_size = 28
  when MH_CIGAM_64, MH_CIGAM_32
    raise "big-endian Mach-O is not supported (offset #{base})"
  else
    return 0
  end

  ncmds = data[base + 16, 4].unpack1("V")
  offset = base + header_size
  patched = 0

  ncmds.times do
    cmd, cmdsize = data[offset, 8].unpack("VV")
    raise "invalid load command size at #{offset}" if cmdsize.nil? || cmdsize < 8

    if cmd == LC_BUILD_VERSION
      data[offset + 8, 4] = [platform].pack("V")
      patched += 1
    end
    offset += cmdsize
  end

  patched
end

# Yields the offset of each member's payload in an `ar` archive.
def each_ar_member(data)
  offset = AR_MAGIC.bytesize

  while offset + AR_HEADER_SIZE <= data.bytesize
    name = data[offset, 16]
    size = data[offset + 48, 10].to_i
    raise "invalid ar member size at #{offset}" if size.zero?

    payload = offset + AR_HEADER_SIZE
    # BSD/macOS `ar` stores names longer than 16 bytes at the start of the
    # payload, counted in `size`.
    if name.start_with?("#1/")
      name_length = name[3..].to_i
      payload += name_length
    end

    yield payload
    offset += AR_HEADER_SIZE + size
    offset += 1 if offset.odd?
  end
end

def patch_file(path, platform)
  data = File.binread(path)
  data.force_encoding(Encoding::BINARY)
  patched = 0

  if data.start_with?(AR_MAGIC)
    each_ar_member(data) { |payload| patched += patch_macho(data, payload, platform) }
  else
    patched = patch_macho(data, 0, platform)
  end

  raise NoBuildVersionError, "#{path}: no LC_BUILD_VERSION found" if patched.zero?

  File.binwrite(path, data)
  patched
end

if $PROGRAM_NAME == __FILE__
  if ARGV.length != 2
    warn "usage: #{File.basename($PROGRAM_NAME)} <file> <platform-number>"
    exit 1
  end

  path, platform = ARGV[0], Integer(ARGV[1])
  count = patch_file(path, platform)
  puts "#{File.basename(path)}: patched #{count} LC_BUILD_VERSION command(s) to platform #{platform}"
end
