#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

# Check the latest version of GoogleMLKit from CocoaPods
def fetch_latest_mlkit_version
  # Use CocoaPods Trunk API
  uri = URI.parse('https://trunk.cocoapods.org/api/v1/pods/GoogleMLKit')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.open_timeout = 10
  http.read_timeout = 10

  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  if response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)
    versions = data['versions'].map { |v| v['name'] }
    # Sort versions and get the latest
    latest = versions.max_by { |v| Gem::Version.new(v) }
    return latest
  else
    raise "Failed to fetch MLKit version info: HTTP #{response.code}"
  end
end

# Get current version from Podfile
def get_current_version
  podfile = File.read('Podfile')
  if podfile =~ /pod\s+'GoogleMLKit\/BarcodeScanning',\s+'~>\s+([0-9.]+)'/
    return $1
  end
  raise "Could not parse version from Podfile"
end

# Main execution
begin
  current_version = get_current_version
  latest_version = fetch_latest_mlkit_version

  puts "Current version: #{current_version}"
  puts "Latest version: #{latest_version}"

  current_gem_version = Gem::Version.new(current_version)
  latest_gem_version = Gem::Version.new(latest_version)

  if latest_gem_version > current_gem_version
    puts "New version available: #{latest_version}"
    puts "UPDATE_AVAILABLE=true"
    puts "NEW_VERSION=#{latest_version}"
    exit 0
  else
    puts "Already up to date"
    puts "UPDATE_AVAILABLE=false"
    exit 0
  end
rescue => e
  puts "Error: #{e.message}"
  exit 1
end
