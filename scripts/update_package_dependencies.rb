#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'

# Matches a package declaration in Package.swift whatever version specifier it
# carries, capturing the version.
def package_url_regex(org, package_name)
  %r{
    \.package\(url:\s*"https://github\.com/#{Regexp.escape(org)}/#{Regexp.escape(package_name)}(?:\.git)?",\s*
    (?:exact|from|\.upToNextMinor\(from|\.upToNextMajor\(from):\s*"([^"]+)"\)?\)
  }x
end

# The version requirement to write for a package.
#
# The resolved Podfile.lock version is the lower bound, not an exact pin: the
# ML Kit binaries were built against these pods' own constraints, which are all
# "up to next major" (`~> 8.0`, `~> 10.0`, `~> 2.4`, `>= 3.3.2 < 4.0`). Pinning
# exactly made this package unusable alongside anything else that depends on
# them -- Firebase 12.19.2 needs GoogleUtilities >= 8.1.3, and an
# `exact: "8.1.0"` here made the dependency graph unsolvable.
#
# nanopb is the exception: CocoaPods numbers it 3.30910.x and SwiftPM 2.30910.x,
# and the pod constraint `~> 3.30910.0` only allows that one minor.
def version_requirement(package_name, version)
  if package_name == 'nanopb'
    %(.upToNextMinor(from: "#{version}"))
  else
    %(from: "#{version}")
  end
end

# Check if a git tag exists in a remote repository
def git_tag_exists?(repo_url, tag)
  tag_check, status = Open3.capture2e('git', 'ls-remote', '--tags', repo_url, "refs/tags/#{tag}")
  status.success? && !tag_check.empty?
rescue => e
  puts "  Warning: Failed to check git tag: #{e.message}"
  false
end

# Get current version of a package from Package.swift
def get_package_version(package_swift, org, package_name)
  pattern = package_url_regex(org, package_name)
  if package_swift =~ pattern
    $1
  end
end

# Update a package version in Package.swift
def update_package_version(package_swift, org, package_name, new_version)
  package_swift.gsub!(
    package_url_regex(org, package_name),
    ".package(url: \"https://github.com/#{org}/#{package_name}.git\", " \
    "#{version_requirement(package_name, new_version)})"
  )
end

# Parse Podfile.lock to extract dependency versions
def parse_podfile_lock
  unless File.exist?('Podfile.lock')
    puts "Error: Podfile.lock not found"
    exit 1
  end

  podfile_lock = File.read('Podfile.lock')
  versions = {}

  # Extract version numbers from PODS section - only top-level entries
  # Match entries like "  - PackageName (1.0.0):" (with exactly 2 spaces before dash)
  # This pattern captures the package name and version string from Podfile.lock
  podfile_lock.scan(/^  - ([^\/\s]+)(?:\/[^\s]+)?\s+\(([^)]+)\):?/) do |name, version_str|
    # Extract only the version number (digits and dots)
    match = version_str.match(/([\d.]+)/)
    if match
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
      # Rewrite unconditionally and compare the result: the requirement form can
      # need updating (an old `exact:` pin) even when the version has not moved.
      before = package_swift.dup
      update_package_version(package_swift, org, package_name, dep_version)

      if package_swift == before
        puts "✓ #{package_name}: #{dep_version} (already up-to-date)"
      else
        puts "→ #{package_name}: #{version_requirement(package_name, dep_version)}"
      end
    end
  end

  # Handle nanopb specially - check if the tag exists before updating
  if dependency_versions['nanopb']
    nanopb_version = dependency_versions['nanopb']
    
    # Get current version from Package.swift
    current_version = get_package_version(package_swift, 'firebase', 'nanopb')
    
    puts
    puts "Checking nanopb..."
    puts "  Podfile.lock version: #{nanopb_version}"
    puts "  Current Package.swift version: #{current_version}"
    
    # Check if the tag exists on firebase/nanopb
    print "  Checking if tag #{nanopb_version} exists in firebase/nanopb... "
    if git_tag_exists?('https://github.com/firebase/nanopb.git', nanopb_version)
      puts "yes"
      before = package_swift.dup
      update_package_version(package_swift, 'firebase', 'nanopb', nanopb_version)
      if package_swift == before
        puts "  ✓ nanopb: #{nanopb_version} (already up-to-date)"
      else
        puts "  → nanopb: #{version_requirement('nanopb', nanopb_version)}"
      end
    else
      puts "no"
      update_package_version(package_swift, 'firebase', 'nanopb', current_version) if current_version
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
