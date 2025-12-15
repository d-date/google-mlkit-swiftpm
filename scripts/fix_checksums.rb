#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'net/http'
require 'uri'

VERSION = ARGV[0] || '9.0.0'

FRAMEWORKS = %w[
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
].freeze

def download_and_checksum(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  # Follow redirects
  max_redirects = 5
  redirects = 0

  while response.is_a?(Net::HTTPRedirection) && redirects < max_redirects
    uri = URI.parse(response['location'])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    redirects += 1
  end

  raise "Failed to download #{url}: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

  Digest::SHA256.hexdigest(response.body)
end

def update_package_swift(checksums)
  package_swift = File.read('Package.swift')

  checksums.each do |name, checksum|
    # Pattern to match the binaryTarget with name, url, and checksum
    pattern = /\.binaryTarget\(\s*name:\s*"#{Regexp.escape(name)}",\s*url:\s*"[^"]+",\s*checksum:\s*"[^"]+"\s*\)/m

    if package_swift =~ pattern
      # Replace only the checksum part
      package_swift.gsub!(
        /\.binaryTarget\(\s*name:\s*"#{Regexp.escape(name)}",\s*url:\s*("[^"]+"),\s*checksum:\s*"[^"]+"\s*\)/m
      ) do |match|
        url = Regexp.last_match(1)
        ".binaryTarget(\n      name: \"#{name}\",\n      url: #{url},\n      checksum: \"#{checksum}\")"
      end
      puts "✓ Updated #{name}"
    else
      puts "⚠ Could not find binaryTarget for #{name}"
    end
  end

  File.write('Package.swift', package_swift)
end

# Main
puts "Calculating checksums from GitHub release #{VERSION}..."
puts ""

checksums = {}

FRAMEWORKS.each_with_index do |name, index|
  url = "https://github.com/d-date/google-mlkit-swiftpm/releases/download/#{VERSION}/#{name}.xcframework.zip"
  print "[#{index + 1}/#{FRAMEWORKS.size}] Downloading #{name}... "

  begin
    checksum = download_and_checksum(url)
    checksums[name] = checksum
    puts "✓"
  rescue => e
    puts "✗ (#{e.message})"
  end
end

puts ""
puts "Updating Package.swift with correct checksums..."
update_package_swift(checksums)

puts ""
puts "Done! Updated #{checksums.size}/#{FRAMEWORKS.size} frameworks."
puts ""
puts "Run 'swift package reset && swift package resolve' to verify."
