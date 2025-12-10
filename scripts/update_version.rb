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

# Update Info.plist files with new version
def update_info_plists(new_version)
  plist_files = Dir.glob('Resources/*-Info.plist')

  plist_files.each do |file|
    content = File.read(file)
    updated = content.gsub(
      /<key>CFBundleShortVersionString<\/key>\s*<string>[^<]+<\/string>/,
      "<key>CFBundleShortVersionString</key>\n\t<string>#{new_version}</string>"
    )
    File.write(file, updated)
    puts "Updated #{File.basename(file)}"
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
  update_podfile(new_version)
  update_info_plists(new_version)
  puts "Version updated successfully to #{new_version}"
  puts "Note: Info.plist files will be copied during build (prepare-info-plist step)"
rescue => e
  puts "Error: #{e.message}"
  exit 1
end
