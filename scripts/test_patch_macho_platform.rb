#!/usr/bin/env ruby
# frozen_string_literal: true

# Self-check for scripts/patch_macho_platform.rb, which walks `ar` and Mach-O
# headers by hand. Builds throwaway object files with clang, including an
# archive with duplicate member names (ML Kit's archives contain three
# `globals.o`), and asserts the in-place patch rewrites every member without
# changing the file's layout.
#
# Usage: ruby scripts/test_patch_macho_platform.rb

require "fileutils"
require "tmpdir"

require_relative "patch_macho_platform"

PLATFORM_IOS = 2
PLATFORM_IOS_SIMULATOR = 7

def run(*args)
  output = IO.popen([*args, { err: [:child, :out] }], &:read)
  raise "command failed: #{args.join(" ")}\n#{output}" unless $?.success?

  output
end

def compile(source, output)
  IO.popen(
    ["xcrun", "--sdk", "iphoneos", "clang", "-c", "-arch", "arm64",
     "-mios-version-min=15.0", "-x", "c", "-", "-o", output],
    "w"
  ) { |io| io.write(source) }
  raise "failed to compile #{output}" unless $?.success?
end

# `otool -l` prints the platform numerically for object files and by name for
# some other file types, so normalise to the number either way.
PLATFORM_NAMES = { "IOS" => PLATFORM_IOS, "IOSSIMULATOR" => PLATFORM_IOS_SIMULATOR }.freeze

def platforms_of(path)
  run("otool", "-l", path)
    .scan(/^\s*platform (\S+)$/).flatten
    .map { |platform| PLATFORM_NAMES.fetch(platform, platform).to_i }
end

def assert(condition, message)
  raise "FAILED: #{message}" unless condition

  puts "ok - #{message}"
end

Dir.mktmpdir do |tmp|
  first = File.join(tmp, "first.o")
  second = File.join(tmp, "second.o")
  compile("int first_symbol(void) { return 1; }", first)
  compile("int second_symbol(void) { return 2; }", second)

  # --- plain Mach-O object -------------------------------------------------
  object = File.join(tmp, "object.o")
  FileUtils.cp(first, object)
  size_before = File.size(object)

  assert(platforms_of(object) == [PLATFORM_IOS], "clang emits a device platform")
  assert(patch_file(object, PLATFORM_IOS_SIMULATOR) == 1, "one load command patched in an object file")
  assert(platforms_of(object) == [PLATFORM_IOS_SIMULATOR], "object file now reports the simulator platform")
  assert(File.size(object) == size_before, "object file size is unchanged")

  # --- ar archive with duplicate member names -----------------------------
  duplicate = File.join(tmp, "first.o.dup")
  FileUtils.cp(second, duplicate)
  archive = File.join(tmp, "archive.a")
  # `ar` stores the basename, so copying `second.o` over a second `first.o`
  # produces two members sharing a name, as ML Kit's archives do.
  FileUtils.mkdir_p(File.join(tmp, "nested"))
  FileUtils.cp(duplicate, File.join(tmp, "nested", "first.o"))
  run("ar", "r", archive, first, File.join(tmp, "nested", "first.o"))
  run("ranlib", archive)

  members = run("ar", "t", archive).split
  size_before = File.size(archive)
  assert(members.count("first.o") == 2, "fixture archive has duplicate member names")

  patched = patch_file(archive, PLATFORM_IOS_SIMULATOR)
  assert(patched == 2, "both duplicate members patched (got #{patched})")
  assert(run("ar", "t", archive).split == members, "archive member list is unchanged")
  assert(File.size(archive) == size_before, "archive size is unchanged")
  assert(platforms_of(archive).uniq == [PLATFORM_IOS_SIMULATOR], "every archive member reports the simulator platform")

  # --- round trip ---------------------------------------------------------
  patch_file(archive, PLATFORM_IOS)
  assert(platforms_of(archive).uniq == [PLATFORM_IOS], "patching back to the device platform works")

  # --- a binary with no platform at all -----------------------------------
  bare = File.join(tmp, "bare.o")
  run("vtool", "-arch", "arm64", "-remove-build-version", PLATFORM_IOS.to_s, "-output", bare, first)
  assert(platforms_of(bare).empty?, "fixture has no platform load command")
  begin
    patch_file(bare, PLATFORM_IOS_SIMULATOR)
    raise "FAILED: expected NoBuildVersionError"
  rescue NoBuildVersionError
    puts "ok - a binary with no LC_BUILD_VERSION is reported, not silently skipped"
  end
end

puts "\nAll checks passed."
