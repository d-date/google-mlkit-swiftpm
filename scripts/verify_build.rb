#!/usr/bin/env ruby
# frozen_string_literal: true

# Verify that the build completed successfully
def verify_xcframeworks
  # Resources/<Name>-Info.plist is the module list: one file per pre-built
  # framework the build repackages. The source modules are compiled here, so
  # they get their Info.plist from their own build and have no template.
  source_modules = %w[GoogleToolboxForMac SSZipArchive]
  required_frameworks =
    Dir.glob('Resources/*-Info.plist').map { |f| File.basename(f, '-Info.plist') } + source_modules

  puts "Checking for XCFramework zip files..."
  missing = []

  required_frameworks.each do |framework|
    zip_file = "GoogleMLKit/#{framework}.xcframework.zip"
    if File.exist?(zip_file)
      size = File.size(zip_file)
      puts "✓ #{framework}.xcframework.zip (#{size} bytes)"
    else
      puts "✗ #{framework}.xcframework.zip - NOT FOUND"
      missing << framework
    end
  end

  # Check for bundle
  bundle_zip = 'GoogleMLKit/GoogleMVFaceDetectorResources.bundle.zip'
  if File.exist?(bundle_zip)
    size = File.size(bundle_zip)
    puts "✓ GoogleMVFaceDetectorResources.bundle.zip (#{size} bytes)"
  else
    puts "✗ GoogleMVFaceDetectorResources.bundle.zip - NOT FOUND"
    missing << 'GoogleMVFaceDetectorResources.bundle'
  end

  if missing.empty?
    puts "\n✓ All XCFrameworks and bundle built successfully!"
    return true
  else
    puts "\n✗ Missing files: #{missing.join(', ')}"
    return false
  end
end

# Verify Package.swift syntax
def verify_package_swift
  puts "\nVerifying Package.swift syntax..."
  result = system('swift package dump-package > /dev/null 2>&1')

  if result
    puts "✓ Package.swift is valid"
    return true
  else
    puts "✗ Package.swift has syntax errors"
    puts "Run: swift package dump-package"
    return false
  end
end

# Verify xcframework-maker is built
def verify_xcframework_maker
  puts "\nChecking xcframework-maker..."
  maker_path = 'xcframework-maker/.build/release/make-xcframework'

  if File.exist?(maker_path) && File.executable?(maker_path)
    puts "✓ xcframework-maker is built and ready"
    return true
  else
    puts "✗ xcframework-maker not found or not executable"
    puts "Run: make bootstrap-builder"
    return false
  end
end

# Verify Info.plist files exist
# These templates are copied verbatim into the frameworks, so a key missing
# here is a key missing in every consumer's app, and App Store Connect is
# unforgiving about it:
#   * no MinimumOSVersion  -> "Invalid MinimumOSVersion ... is ''" (90530)
#   * no CFBundleSupportedPlatforms / UIRequiredDeviceCapabilities -> Xcode
#     rebuilds the embedded stub against the *app's* deployment target, and the
#     upload fails post-processing with "does not support the minimum OS
#     Version specified in the Info.plist" (90208)
# MLKitNaturalLanguage shipped with a minimal hand-written plist and hit both.
REQUIRED_PLIST_KEYS = %w[
  CFBundleExecutable
  CFBundleIdentifier
  CFBundleShortVersionString
  CFBundleSupportedPlatforms
  MinimumOSVersion
  UIRequiredDeviceCapabilities
].freeze

# Resources/ and the Makefile's MLKIT_MODULES have to name the same modules:
# prepare-info-plist copies one per entry, so a module added to one and not the
# other either fails the build or silently ships without an Info.plist.
def verify_module_lists
  puts "\nChecking the module lists agree..."
  makefile = File.read('Makefile')[/^MLKIT_MODULES\s*=((?:.*\\\n)*.*)$/, 1].to_s
  declared = makefile.gsub('\\', ' ').split.sort
  templates = Dir.glob('Resources/*-Info.plist').map { |f| File.basename(f, '-Info.plist') }.sort

  if declared == templates
    puts "✓ #{declared.length} modules, matching Resources/ and MLKIT_MODULES"
    return true
  end

  puts "✗ only in MLKIT_MODULES: #{(declared - templates).join(', ')}" unless (declared - templates).empty?
  puts "✗ only in Resources/: #{(templates - declared).join(', ')}" unless (templates - declared).empty?
  false
end

def verify_info_plists
  require 'json'

  puts "\nChecking Info.plist files..."
  plists = Dir.glob('Resources/*-Info.plist').sort
  problems = []

  if plists.empty?
    puts '✗ No Info.plist templates found in Resources/'
    return false
  end

  plists.each do |path|
    name = File.basename(path)
    contents = JSON.parse(`/usr/bin/plutil -convert json -o - #{path}`)
    empty = REQUIRED_PLIST_KEYS.reject do |key|
      value = contents[key]
      !value.nil? && value != '' && value != []
    end

    if empty.empty?
      puts "✓ #{name}"
    else
      puts "✗ #{name} - missing or empty: #{empty.join(', ')}"
      problems << name
    end
  rescue JSON::ParserError
    puts "✗ #{name} - not a readable plist"
    problems << name
  end

  if problems.empty?
    puts '✓ All Info.plist templates carry the keys consumers need'
    true
  else
    puts "✗ Info.plist problems in: #{problems.join(', ')}"
    false
  end
end

# Main execution
puts "=== Build Verification ==="
puts ""

results = {
  module_lists: verify_module_lists,
  info_plists: verify_info_plists,
  xcframework_maker: verify_xcframework_maker,
  xcframeworks: verify_xcframeworks,
  package_swift: verify_package_swift
}

puts ""
puts "=== Summary ==="

if results.values.all?
  puts "✓ All checks passed!"
  exit 0
else
  puts "✗ Some checks failed"
  results.each do |check, passed|
    status = passed ? "✓" : "✗"
    puts "  #{status} #{check}"
  end
  exit 1
end
