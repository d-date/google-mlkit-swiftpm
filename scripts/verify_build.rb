#!/usr/bin/env ruby
# frozen_string_literal: true

# Verify that the build completed successfully
def verify_xcframeworks
  required_frameworks = [
    'MLKitBarcodeScanning',
    'MLKitFaceDetection',
    'MLImage',
    'MLKitCommon',
    'MLKitVision',
    'GoogleToolboxForMac',
    'GoogleUtilitiesComponents'
  ]

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

  if missing.empty?
    puts "\n✓ All XCFrameworks built successfully!"
    return true
  else
    puts "\n✗ Missing XCFrameworks: #{missing.join(', ')}"
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
def verify_info_plists
  puts "\nChecking Info.plist files..."
  required_plists = [
    'MLKitCommon-Info.plist',
    'MLKitBarcodeScanning-Info.plist',
    'MLKitFaceDetection-Info.plist',
    'MLKitVision-Info.plist',
    'MLImage-Info.plist'
  ]

  missing = []
  required_plists.each do |plist|
    path = "Resources/#{plist}"
    if File.exist?(path)
      puts "✓ #{plist}"
    else
      puts "✗ #{plist} - NOT FOUND"
      missing << plist
    end
  end

  if missing.empty?
    puts "✓ All Info.plist files present"
    return true
  else
    puts "✗ Missing Info.plist files: #{missing.join(', ')}"
    return false
  end
end

# Main execution
puts "=== Build Verification ==="
puts ""

results = {
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
