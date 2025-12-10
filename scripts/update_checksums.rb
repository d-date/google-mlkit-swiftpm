#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'

# Calculate SHA256 checksum for a file
def calculate_checksum(file_path)
  Digest::SHA256.file(file_path).hexdigest
end

# Update Package.swift with new version and checksums
def update_package_swift(version, checksums)
  package_swift = File.read('Package.swift')

  # Update each binary target with new URL and checksum
  checksums.each do |name, checksum|
    # Match the binaryTarget block for this framework
    package_swift.gsub!(
      /\.binaryTarget\(\s*name:\s*"#{name}",\s*url:\s*"[^"]+",\s*checksum:\s*"[^"]+"\)/m
    ) do |match|
      match.gsub(
        %r{url:\s*"https://github\.com/d-date/google-mlkit-swiftpm/releases/download/[^/]+/},
        "url: \"https://github.com/d-date/google-mlkit-swiftpm/releases/download/#{version}/"
      ).gsub(
        /checksum:\s*"[^"]+"/,
        "checksum: \"#{checksum}\""
      )
    end
  end

  File.write('Package.swift', package_swift)
  puts "Updated Package.swift with version #{version} and checksums"
end

# Scan GoogleMLKit directory for xcframework.zip files and calculate checksums
def scan_and_calculate_checksums
  checksums = {}

  Dir.glob('GoogleMLKit/*.xcframework.zip').each do |file|
    framework_name = File.basename(file, '.xcframework.zip')
    checksum = calculate_checksum(file)
    checksums[framework_name] = checksum
    puts "#{framework_name}: #{checksum}"
  end

  checksums
end

# Main execution
if ARGV.length != 1
  puts "Usage: #{$0} <version>"
  exit 1
end

version = ARGV[0]

begin
  puts "Calculating checksums for XCFrameworks..."
  checksums = scan_and_calculate_checksums

  if checksums.empty?
    raise "No XCFramework zip files found in GoogleMLKit directory"
  end

  puts "\nUpdating Package.swift..."
  update_package_swift(version, checksums)

  puts "\nSuccessfully updated Package.swift"
rescue => e
  puts "Error: #{e.message}"
  exit 1
end
