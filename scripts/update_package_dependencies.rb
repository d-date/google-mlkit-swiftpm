#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'

# Parse Podfile.lock to extract dependency versions
def parse_podfile_lock
  unless File.exist?('Podfile.lock')
    puts "Error: Podfile.lock not found"
    exit 1
  end

  podfile_lock = File.read('Podfile.lock')
  versions = {}

  # Extract version numbers from PODS section - only top-level entries
  # Match entries like "  - GoogleDataTransport (10.1.0):" (with exactly 2 spaces before dash)
  podfile_lock.scan(/^  - ([^\/\s]+)(?:\/[^\s]+)?\s+\(([^)]+)\):?/) do |name, version_str|
    # Extract only the version number (digits and dots)
    if match = version_str.match(/([\d.]+)/)
      version = match[1]
      versions[name] = version
    end
  end

  versions
end

# Update Package.swift with dependency versions from Podfile.lock
def update_package_swift(dependency_versions)
  unless File.exist?('Package.swift')
    puts "Error: Package.swift not found"
    exit 1
  end

  package_swift = File.read('Package.swift')
  original_package_swift = package_swift.dup

  puts "Updating Package.swift dependencies from Podfile.lock..."
  puts

  # Update standard dependencies
  {
    'GoogleDataTransport' => ['google', 'GoogleDataTransport'],
    'GoogleUtilities' => ['google', 'GoogleUtilities'],
    'GTMSessionFetcher' => ['google', 'gtm-session-fetcher'],
    'PromisesObjC' => ['google', 'promises']
  }.each do |podfile_name, (org, package_name)|
    if dependency_versions[podfile_name]
      dep_version = dependency_versions[podfile_name]
      
      # Get current version from Package.swift
      current_version = nil
      if package_swift =~ /\.package\(url:\s*"https:\/\/github\.com\/#{Regexp.escape(org)}\/#{Regexp.escape(package_name)}(?:\.git)?",\s*exact:\s*"([^"]+)"\)/
        current_version = $1
      end
      
      if current_version == dep_version
        puts "✓ #{package_name}: #{dep_version} (already up-to-date)"
      else
        puts "→ #{package_name}: #{current_version} → #{dep_version}"
        # Update .package declaration - match any version specifier
        package_swift.gsub!(
          /\.package\(url:\s*"https:\/\/github\.com\/#{Regexp.escape(org)}\/#{Regexp.escape(package_name)}(?:\.git)?",\s*exact:\s*"[^"]+"\)/,
          ".package(url: \"https://github.com/#{org}/#{package_name}.git\", exact: \"#{dep_version}\")"
        )
      end
    end
  end

  # Handle nanopb specially - check if the tag exists before updating
  if dependency_versions['nanopb']
    nanopb_version = dependency_versions['nanopb']
    
    # Get current version from Package.swift
    current_version = nil
    if package_swift =~ /\.package\(url:\s*"https:\/\/github\.com\/firebase\/nanopb(?:\.git)?",\s*exact:\s*"([^"]+)"\)/
      current_version = $1
    end
    
    puts
    puts "Checking nanopb..."
    puts "  Podfile.lock version: #{nanopb_version}"
    puts "  Current Package.swift version: #{current_version}"
    
    # Check if the tag exists on firebase/nanopb
    print "  Checking if tag #{nanopb_version} exists in firebase/nanopb... "
    tag_check, status = Open3.capture2e('git', 'ls-remote', '--tags', 'https://github.com/firebase/nanopb.git', "refs/tags/#{nanopb_version}")
    
    if status.success? && !tag_check.empty?
      puts "yes"
      if current_version == nanopb_version
        puts "  ✓ nanopb: #{nanopb_version} (already up-to-date)"
      else
        puts "  → nanopb: #{current_version} → #{nanopb_version}"
        package_swift.gsub!(
          /\.package\(url:\s*"https:\/\/github\.com\/firebase\/nanopb(?:\.git)?",\s*exact:\s*"[^"]+"\)/,
          ".package(url: \"https://github.com/firebase/nanopb.git\", exact: \"#{nanopb_version}\")"
        )
      end
    else
      puts "no"
      puts "  ℹ nanopb: Keeping #{current_version} (CocoaPods version #{nanopb_version} not available in SwiftPM)"
      puts "           Note: CocoaPods and firebase/nanopb use different versioning schemes"
    end
  end

  # Write changes if any were made
  if package_swift != original_package_swift
    File.write('Package.swift', package_swift)
    puts
    puts "✓ Package.swift updated successfully"
    true
  else
    puts
    puts "✓ All dependencies are already up-to-date"
    false
  end
end

# Main execution
begin
  puts "Parsing Podfile.lock for dependency versions..."
  dependency_versions = parse_podfile_lock
  
  if dependency_versions.empty?
    puts "Error: No dependency versions found in Podfile.lock"
    exit 1
  end
  
  puts "Found #{dependency_versions.size} dependencies in Podfile.lock"
  puts
  
  updated = update_package_swift(dependency_versions)
  
  exit 0
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace if ENV['DEBUG']
  exit 1
end
