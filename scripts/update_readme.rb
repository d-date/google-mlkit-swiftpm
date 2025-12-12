#!/usr/bin/env ruby
# frozen_string_literal: true

# Update README.md with new MLKit version
# This script updates:
# 1. Installation example version
# 2. Bundle download link version

def update_readme(new_version)
  readme_path = 'README.md'

  unless File.exist?(readme_path)
    puts "Error: README.md not found"
    exit 1
  end

  content = File.read(readme_path)
  original_content = content.dup

  # Update Installation example (.package line)
  # Example: .package(url: "https://github.com/d-date/google-mlkit-swiftpm", from: "5.0.0")
  content = content.gsub(
    /\.package\(url: "https:\/\/github\.com\/d-date\/google-mlkit-swiftpm", from: "[^"]+"\)/,
    ".package(url: \"https://github.com/d-date/google-mlkit-swiftpm\", from: \"#{new_version}\")"
  )

  # Update bundle download link
  # Example: Download `GoogleMVFaceDetectorResources.bundle` from [Release](https://github.com/d-date/google-mlkit-swiftpm/releases/download/3.2.0/GoogleMVFaceDetectorResources.bundle.zip)
  content = content.gsub(
    %r{https://github\.com/d-date/google-mlkit-swiftpm/releases/download/[^/]+/GoogleMVFaceDetectorResources\.bundle\.zip},
    "https://github.com/d-date/google-mlkit-swiftpm/releases/download/#{new_version}/GoogleMVFaceDetectorResources.bundle.zip"
  )

  # Check if any changes were made
  if content == original_content
    puts "Warning: No version references found in README.md"
    puts "Expected to update:"
    puts "  1. Installation .package(url:..., from: \"VERSION\")"
    puts "  2. Bundle download link with version in URL"
    return
  end

  File.write(readme_path, content)
  puts "✓ Updated README.md to version #{new_version}"

  # Show what was updated
  puts "\nUpdated sections:"
  if content.include?(".package(url: \"https://github.com/d-date/google-mlkit-swiftpm\", from: \"#{new_version}\")")
    puts "  - Installation example"
  end
  if content.include?("releases/download/#{new_version}/GoogleMVFaceDetectorResources.bundle.zip")
    puts "  - Bundle download link"
  end
end

# Main execution
if ARGV.length != 1
  puts "Usage: #{File.basename($PROGRAM_NAME)} <version>"
  puts "Example: #{File.basename($PROGRAM_NAME)} 5.1.0"
  exit 1
end

new_version = ARGV[0]

# Validate semantic versioning format (X.Y.Z)
unless new_version =~ /^\d+\.\d+\.\d+$/
  puts "Error: Version '#{new_version}' is not in semantic versioning format (X.Y.Z)"
  exit 1
end

begin
  puts "Updating README.md to MLKit version #{new_version}..."
  update_readme(new_version)
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace if ENV['DEBUG']
  exit 1
end
