#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

# Update Podfile with new MLKit version
def update_podfile(new_version)
  podfile = File.read('Podfile')
  updated = podfile.gsub(
    /pod\s+'GoogleMLKit\/(FaceDetection|BarcodeScanning)',\s+'~>\s+[0-9]+(?:\.[0-9]+)*'/,
    "pod 'GoogleMLKit/\\1', '~> #{new_version}'"
  )
  File.write('Podfile', updated)
  puts "Updated Podfile to version #{new_version}"
end

# Parse Podfile.lock to extract framework versions
def parse_podfile_lock
  unless File.exist?('Podfile.lock')
    puts "Warning: Podfile.lock not found. Info.plist files will not be updated."
    puts "         Run 'bundle exec pod install' first, then run this script again."
    return {}
  end

  podfile_lock = File.read('Podfile.lock')
  versions = {}

  # Extract version numbers from PODS section - only top-level entries
  # Match entries like "  - MLKitCommon (12.0.0):" (with exactly 2 spaces before dash)
  podfile_lock.scan(/^  - ([^\/\s]+)(?:\/[^\s]+)?\s+\(([^)]+)\):?/) do |name, version_str|
    # Extract only the version number (digits and dots)
    if match = version_str.match(/([\d.]+)/)
      version = match[1]
      versions[name] = version
    end
  end

  versions
end

# Map Info.plist filename to framework name in Podfile.lock
PLIST_TO_FRAMEWORK = {
  'MLKitCommon-Info.plist' => 'MLKitCommon',
  'MLKitBarcodeScanning-Info.plist' => 'MLKitBarcodeScanning',
  'MLKitFaceDetection-Info.plist' => 'MLKitFaceDetection',
  'MLKitVision-Info.plist' => 'MLKitVision',
  'MLImage-Info.plist' => 'MLImage'
}.freeze

# Update Info.plist files with versions from Podfile.lock
def update_info_plists_from_podfile_lock(framework_versions)
  return if framework_versions.empty?

  plist_files = Dir.glob('Resources/*-Info.plist')

  plist_files.each do |file|
    basename = File.basename(file)
    framework_name = PLIST_TO_FRAMEWORK[basename]

    unless framework_name
      puts "Warning: Unknown Info.plist file: #{basename}, skipping"
      next
    end

    version = framework_versions[framework_name]
    unless version
      puts "Warning: Version not found for #{framework_name} in Podfile.lock, skipping #{basename}"
      next
    end

    content = File.read(file)
    updated = content.gsub(
      /<key>CFBundleShortVersionString<\/key>\s*<string>[^<]+<\/string>/,
      "<key>CFBundleShortVersionString</key>\n\t<string>#{version}</string>"
    )
    File.write(file, updated)
    puts "Updated #{basename} to version #{version}"
  end
end

# Main execution
if ARGV.length != 1
  puts "Usage: #{File.basename($PROGRAM_NAME)} <version>"
  exit 1
end

new_version = ARGV[0]

# Validate semantic versioning format (X.Y.Z)
unless new_version =~ /^\d+\.\d+\.\d+$/
  puts "Error: Version '#{new_version}' is not in semantic versioning format (X.Y.Z)"
  exit 1
end

begin
  puts "Updating Podfile to MLKit version #{new_version}..."
  update_podfile(new_version)

  # Run pod update to fetch new versions and capture output
  puts "\nRunning pod update to fetch MLKit #{new_version}..."
  require 'open3'

  pod_output, pod_status = Open3.capture2e('bundle', 'exec', 'pod', 'update')
  File.write('pod_update.log', pod_output)

  if pod_status.success?
    puts "✓ Pod update completed successfully"
    puts "  Log saved to pod_update.log"
  else
    puts "Warning: Pod update exited with status #{pod_status.exitstatus}"
    puts "  Log saved to pod_update.log for review"
  end

  puts "\nParsing Podfile.lock for framework versions..."
  framework_versions = parse_podfile_lock

  if framework_versions.empty?
    puts "\nWarning: No framework versions found in Podfile.lock"
    puts "Info.plist files will not be updated with specific framework versions"
    puts "Run 'bundle exec pod install' to generate Podfile.lock, then run this script again"
  else
    puts "Found #{framework_versions.size} framework versions in Podfile.lock"
    puts "\nUpdating Info.plist files with framework-specific versions..."
    update_info_plists_from_podfile_lock(framework_versions)
  end

  puts "\n✓ Version update completed successfully"
  puts "Note: Info.plist files will be copied during build (prepare-info-plist step)"
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace if ENV['DEBUG']
  exit 1
end
