#!/usr/bin/env ruby
# frozen_string_literal: true

# Post-processes every XCFramework in a directory so SwiftPM consumers get a
# working package. Two things happen per XCFramework, in this order:
#
# 1. An arm64 architecture is injected into the simulator slice, derived from
#    the device arm64 slice by rewriting the Mach-O platform. ML Kit's
#    pre-built binaries carry no arm64 simulator code, and Xcode 26 dropped
#    Rosetta simulators, so without this the package cannot run in the
#    Simulator on Apple Silicon at all.
#
# 2. Framework binaries that are bare Mach-O object files are converted into
#    `ar` archives. Xcode treats a framework whose binary is an object file as
#    a *dynamic* framework and relinks it, dead-stripping unreferenced data --
#    which is how MLKitTextRecognitionCommon lost its ~60MB OCR model and
#    crashed with "Invalid model path.".
#
# Order matters: the platform rewrite must run before the `ar` conversion,
# because `vtool` does not understand `ar` archives.
#
# Usage: postprocess_xcframeworks.rb [directory]   (default: GoogleMLKit)

require "json"
require "fileutils"
require "shellwords"
require "tmpdir"

require_relative "patch_macho_platform"

PLATFORM_IOS_SIMULATOR = 7
FAT_MAGICS = [0xcafebabe, 0xbebafeca].freeze
MACHO_MAGICS = [0xfeedfacf, 0xcffaedfe, 0xfeedface, 0xcefaedfe].freeze
MH_OBJECT = 1
# Matches IPHONEOS_DEPLOYMENT_TARGET in the Makefile.
MINOS = ENV.fetch("IPHONEOS_DEPLOYMENT_TARGET", "15.0")

def sh(*args)
  output = IO.popen([*args, { err: [:child, :out] }], &:read)
  raise "command failed: #{args.shelljoin}\n#{output}" unless $?.success?

  output
end

# :ar, :object, :macho (dylib/executable), :fat or :unknown
def binary_kind(path)
  head = File.binread(path, 16).to_s
  return :ar if head.start_with?(AR_MAGIC)

  magic = head[0, 4].to_s.unpack1("V")
  return :fat if FAT_MAGICS.include?(magic)
  return :unknown unless MACHO_MAGICS.include?(magic)

  head[12, 4].unpack1("V") == MH_OBJECT ? :object : :macho
end

def archs(path)
  sh("lipo", "-archs", path).split
end

# xcframework-maker emits single-architecture *fat* wrappers, so a slice
# binary has to be unwrapped even when it holds only the architecture we want.
def thin(path, arch, output)
  if binary_kind(path) == :fat
    sh("lipo", "-thin", arch, path, "-output", output)
  else
    FileUtils.cp(path, output)
  end
end

def simulator_sdk_version
  @simulator_sdk_version ||= sh("xcrun", "--sdk", "iphonesimulator", "--show-sdk-version").strip
end

# Rewrites the platform of an object file that carries LC_VERSION_MIN_IPHONEOS
# instead of LC_BUILD_VERSION. Four ML Kit binaries ship with no platform load
# command at all (MLKitBarcodeScanning, MLKitFaceDetection,
# MLKitTextRecognitionCommon, MLKitVisionKit); xcframework-maker gives those a
# LC_VERSION_MIN_IPHONEOS so `-create-xcframework` can identify the platform,
# and only `vtool` can swap that for the LC_BUILD_VERSION a simulator slice
# needs -- a version-min command cannot express "arm64 simulator".
# ponytail: if vtool ever runs out of header space here, relinking with
# `ld -r -platform_version ios-simulator` produces the same result.
def set_simulator_platform(path)
  Dir.mktmpdir do |tmp|
    patched = File.join(tmp, File.basename(path))
    sh("vtool", "-arch", "arm64",
       "-set-build-version", PLATFORM_IOS_SIMULATOR.to_s, MINOS, simulator_sdk_version,
       "-replace", "-output", patched, path)
    FileUtils.cp(patched, path)
  end
end

# Turns a copy of the device arm64 binary into an arm64 simulator binary.
def make_simulator_binary(device_binary, output)
  thin(device_binary, "arm64", output)

  begin
    # Patching in place keeps an archive's member layout and symbol index
    # byte-identical. Extracting and repacking would collapse ML Kit's
    # duplicate member names (three `globals.o` in MLKitCommon) into duplicate
    # symbols at link time.
    patch_file(output, PLATFORM_IOS_SIMULATOR)
  rescue NoBuildVersionError
    set_simulator_platform(output)
  end
end

# Converts a framework binary that is a bare Mach-O object into an `ar`
# archive, per architecture, so Xcode links it statically instead of relinking
# it into a dynamic framework. Returns true when the binary was converted.
def make_static(binary)
  return false unless [:object, :fat].include?(binary_kind(binary))

  Dir.mktmpdir do |tmp|
    archives = archs(binary).map do |arch|
      object = File.join(tmp, "#{arch}.o")
      thin(binary, arch, object)
      break nil unless binary_kind(object) == :object

      archive = File.join(tmp, "#{arch}.a")
      sh("ar", "r", archive, object)
      sh("ranlib", archive)
      archive
    end
    return false if archives.nil?

    if archives.one?
      FileUtils.cp(archives.first, binary)
    else
      sh("lipo", "-create", *archives, "-output", binary)
    end
  end

  true
end

def read_plist(path)
  JSON.parse(sh("plutil", "-convert", "json", "-o", "-", path))
end

def write_plist(path, hash)
  IO.popen(["plutil", "-convert", "xml1", "-o", path, "-"], "w") { |io| io.write(hash.to_json) }
  raise "failed to write #{path}" unless $?.success?
end

# A slice holds either a framework bundle, whose binary sits inside it, or a
# bare static library, which is the binary.
def slice_binary(xcframework, slice)
  path = File.join(xcframework, slice["LibraryIdentifier"], slice["LibraryPath"])
  return path unless File.extname(path) == ".framework"

  File.join(path, File.basename(path, ".framework"))
end

# Keeps the slice directory name in step with its architectures, matching what
# `xcodebuild -create-xcframework` would have produced.
def rename_slice(xcframework, slice)
  variant = slice["SupportedPlatformVariant"]
  identifier = [
    slice["SupportedPlatform"],
    slice["SupportedArchitectures"].join("_"),
    variant,
  ].compact.join("-")
  return if identifier == slice["LibraryIdentifier"]

  FileUtils.mv(File.join(xcframework, slice["LibraryIdentifier"]), File.join(xcframework, identifier))
  slice["LibraryIdentifier"] = identifier
end

def add_arm64_simulator(xcframework, device, simulator)
  device_binary = slice_binary(xcframework, device)
  simulator_binary = slice_binary(xcframework, simulator)
  injected = "#{simulator_binary}-arm64"

  make_simulator_binary(device_binary, injected)
  # Both slices must be the same kind of binary before they can be merged.
  make_static(simulator_binary)
  make_static(injected)
  sh("lipo", "-create", simulator_binary, injected, "-output", simulator_binary)
  FileUtils.rm_f(injected)

  simulator["SupportedArchitectures"] = (simulator["SupportedArchitectures"] + ["arm64"]).sort
  rename_slice(xcframework, simulator)
end

def process(xcframework)
  info = File.join(xcframework, "Info.plist")
  plist = read_plist(info)
  libraries = plist["AvailableLibraries"]
  device = libraries.find { |l| l["SupportedPlatform"] == "ios" && l["SupportedPlatformVariant"].nil? }
  simulator = libraries.find { |l| l["SupportedPlatformVariant"] == "simulator" }
  actions = []

  if device && simulator && !simulator["SupportedArchitectures"].include?("arm64")
    add_arm64_simulator(xcframework, device, simulator)
    write_plist(info, plist)
    actions << "arm64-simulator"
  end

  converted = libraries.count { |library| make_static(slice_binary(xcframework, library)) }
  actions << "static x#{converted}" if converted.positive?

  puts format("%-34s %s", File.basename(xcframework), actions.empty? ? "unchanged" : actions.join(", "))
end

if $PROGRAM_NAME == __FILE__
  directory = ARGV[0] || "GoogleMLKit"
  xcframeworks = Dir.glob(File.join(directory, "*.xcframework")).sort
  abort "no XCFrameworks found in #{directory}" if xcframeworks.empty?

  xcframeworks.each { |xcframework| process(xcframework) }
end
