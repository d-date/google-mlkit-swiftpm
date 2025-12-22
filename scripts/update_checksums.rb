#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'open3'

# Calculate SHA256 checksum for a file
def calculate_checksum(file_path)
  Digest::SHA256.file(file_path).hexdigest
end

# Regex pattern for matching package declarations in Package.swift
def package_url_regex(org, package_name)
  /\.package\(url:\s*"https:\/\/github\.com\/#{Regexp.escape(org)}\/#{Regexp.escape(package_name)}(?:\.git)?",\s*exact:\s*"([^"]+)"\)/
end

# Parse Podfile.lock to extract dependency versions
def parse_podfile_lock
  podfile_lock = File.read('Podfile.lock')
  versions = {}

  # Extract version numbers from PODS section - only top-level entries
  # Match entries like "  - GoogleDataTransport (10.1.0):" (with exactly 2 spaces before dash)
  podfile_lock.scan(/^  - ([^\/\s]+)(?:\/[^\s]+)?\s+\(([^)]+)\):?/) do |name, version_str|
    # Extract only the version number (digits and dots)
    match = version_str.match(/([\d.]+)/)
    if match
      version = match[1]
      # Normalize version: if it has only 1 dot (e.g., "10.0" or "8.0"), append ".0"
      version = "#{version}.0" if version.count('.') == 1
      versions[name] = version
    end
  end

  versions
end

# Update Package.swift with new version, checksums, and dependency versions
def update_package_swift(version, checksums, dependency_versions)
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

  # Update dependency versions
  {
    'GoogleDataTransport' => ['google', 'GoogleDataTransport'],
    'GoogleUtilities' => ['google', 'GoogleUtilities'],
    'GTMSessionFetcher' => ['google', 'gtm-session-fetcher'],
    'PromisesObjC' => ['google', 'promises']
  }.each do |podfile_name, (org, package_name)|
    if dependency_versions[podfile_name]
      dep_version = dependency_versions[podfile_name]
      puts "  Updating #{package_name} to #{dep_version}"
      # Update .package declaration - match any version specifier
      package_swift.gsub!(
        /\.package\(url:\s*"https:\/\/github\.com\/#{Regexp.escape(org)}\/#{Regexp.escape(package_name)}(\.git)?",\s*exact:\s*"[^"]+"\)/,
        ".package(url: \"https://github.com/#{org}/#{package_name}.git\", exact: \"#{dep_version}\")"
      )
    end
  end

  # Handle nanopb specially - check if the tag exists before updating
  if dependency_versions['nanopb']
    nanopb_version = dependency_versions['nanopb']
    puts "  Checking nanopb #{nanopb_version}..."
    
    begin
      # Check if the tag exists on firebase/nanopb
      tag_check, status = Open3.capture2e('git', 'ls-remote', '--tags', 'https://github.com/firebase/nanopb.git', "refs/tags/#{nanopb_version}")
      
      if status.success? && !tag_check.empty?
        puts "  Updating nanopb to #{nanopb_version}"
        package_swift.gsub!(
          package_url_regex('firebase', 'nanopb'),
          ".package(url: \"https://github.com/firebase/nanopb.git\", exact: \"#{nanopb_version}\")"
        )
      else
        puts "  Warning: nanopb #{nanopb_version} tag not found in firebase/nanopb repository"
        puts "           Keeping current version in Package.swift"
        puts "           Note: CocoaPods and SwiftPM use different versioning schemes for nanopb"
      end
    rescue => e
      puts "  Warning: Failed to check nanopb tag: #{e.message}"
      puts "           Keeping current version in Package.swift"
    end
  end

  File.write('Package.swift', package_swift)
  puts "Updated Package.swift with version #{version}, checksums, and dependency versions"
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
  puts "Usage: #{File.basename($PROGRAM_NAME)} <version>"
  exit 1
end

version = ARGV[0]

# Validate semantic versioning format (X.Y.Z)
unless version =~ /^\d+\.\d+\.\d+$/
  puts "Error: Version '#{version}' is not in semantic versioning format (X.Y.Z)"
  exit 1
end
begin
  puts "Calculating checksums for XCFrameworks..."
  checksums = scan_and_calculate_checksums

  if checksums.empty?
    raise "No XCFramework zip files found in GoogleMLKit directory"
  end

  puts "\nParsing Podfile.lock for dependency versions..."
  dependency_versions = parse_podfile_lock
  puts "Found #{dependency_versions.size} dependencies"

  puts "\nUpdating Package.swift..."
  update_package_swift(version, checksums, dependency_versions)

  puts "\nSuccessfully updated Package.swift"
rescue => e
  puts "Error: #{e.message}"
  exit 1
end
