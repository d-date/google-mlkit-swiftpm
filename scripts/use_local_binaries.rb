#!/usr/bin/env ruby
# frozen_string_literal: true

# Rewrites every `.binaryTarget` in Package.swift to point at the XCFrameworks
# in GoogleMLKit/ instead of a GitHub Release asset, so the package can be
# built and archived before anything is published.
#
# Replaces the block of commented-out `path:` targets this file used to carry
# for the same purpose. Restore with `git checkout Package.swift`.
#
# Usage: use_local_binaries.rb [package-path] [xcframework-directory]

package_path = ARGV[0] || "Package.swift"
directory = ARGV[1] || "GoogleMLKit"

source = File.read(package_path)
rewritten = source.gsub(
  /^(\ *\.binaryTarget\(\s*name: "([^"]+)",)\s*url: "[^"]*",\s*checksum: "[^"]*"\)/m
) { "#{Regexp.last_match(1)}\n      path: \"#{directory}/#{Regexp.last_match(2)}.xcframework\")" }

count = rewritten.scan(/path: "#{Regexp.escape(directory)}\//).length
abort "no URL-based binary targets found in #{package_path}" if count.zero?

missing = rewritten.scan(/path: "(#{Regexp.escape(directory)}\/[^"]+)"/).flatten.reject { |path| Dir.exist?(path) }
abort "missing XCFrameworks:\n  #{missing.join("\n  ")}" unless missing.empty?

File.write(package_path, rewritten)
puts "Pointed #{count} binary target(s) at #{directory}/"
