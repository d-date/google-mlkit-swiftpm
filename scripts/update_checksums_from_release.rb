#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'net/http'
require 'uri'
require 'tempfile'

def download_and_checksum(url)
  uri = URI.parse(url)
  response = Net::HTTP.get_response(uri)

  # Follow redirects
  while response.is_a?(Net::HTTPRedirection)
    uri = URI.parse(response['location'])
    response = Net::HTTP.get_response(uri)
  end

  raise "Failed to download #{url}: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

  Digest::SHA256.hexdigest(response.body)
end

def update_package_swift(version, checksums)
  package_swift = File.read('Package.swift')

  checksums.each do |name, checksum|
    url = "https://github.com/d-date/google-mlkit-swiftpm/releases/download/#{version}/#{name}.xcframework.zip"

    # Match the binaryTarget block for this framework
    old_pattern = /\.binaryTarget\(\s*name:\s*"#{Regexp.escape(name)}",\s*url:\s*"[^"]+",\s*checksum:\s*"[^"]+"\s*\)/m

    if package_swift =~ old_pattern
      new_target = ".binaryTarget(\n      name: \"#{name}\",\n      url: \"#{url}\",\n      checksum: \"#{checksum}\")"
      package_swift.gsub!(old_pattern, new_target)
      puts "✓ Updated #{name}"
    else
      puts "⚠ Could not find binaryTarget for #{name}"
    end
  end

  File.write('Package.swift', package_swift)
end

# Main
if ARGV.length != 1
  puts "Usage: #{File.basename($PROGRAM_NAME)} <version>"
  exit 1
end

version = ARGV[0]

frameworks = %w[
  GoogleToolboxForMac
  MLImage
  MLKitBarcodeScanning
  MLKitCommon
  MLKitFaceDetection
  MLKitImageLabeling
  MLKitImageLabelingCustom
  MLKitLanguageID
  MLKitObjectDetection
  MLKitObjectDetectionCustom
  MLKitPoseDetection
  MLKitPoseDetectionAccurate
  MLKitSegmentationSelfie
  MLKitSmartReply
  MLKitTextRecognition
  MLKitTextRecognitionChinese
  MLKitTextRecognitionDevanagari
  MLKitTextRecognitionJapanese
  MLKitTextRecognitionKorean
  MLKitTranslate
  MLKitVision
]

puts "Downloading and calculating checksums for #{frameworks.size} frameworks from release #{version}..."
puts ""

checksums = {}

frameworks.each_with_index do |name, index|
  url = "https://github.com/d-date/google-mlkit-swiftpm/releases/download/#{version}/#{name}.xcframework.zip"
  print "[#{index + 1}/#{frameworks.size}] Downloading #{name}... "

  begin
    checksum = download_and_checksum(url)
    checksums[name] = checksum
    puts "✓"
  rescue => e
    puts "✗ (#{e.message})"
  end
end

puts ""
puts "Updating Package.swift..."
update_package_swift(version, checksums)

puts ""
puts "Done! Updated #{checksums.size}/#{frameworks.size} frameworks."
