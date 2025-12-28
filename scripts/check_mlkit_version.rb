#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

# Configuration constants
MAX_RETRIES = (ENV['MLKIT_MAX_RETRIES'] || 3).to_i
HTTP_OPEN_TIMEOUT = (ENV['MLKIT_HTTP_OPEN_TIMEOUT'] || 30).to_i
HTTP_READ_TIMEOUT = (ENV['MLKIT_HTTP_READ_TIMEOUT'] || 30).to_i

# Custom exception for network errors
class NetworkError < StandardError; end

# Check the latest version of GoogleMLKit from CocoaPods
def fetch_latest_mlkit_version
  # Use CocoaPods Trunk API
  uri = URI.parse('https://trunk.cocoapods.org/api/v1/pods/GoogleMLKit')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.open_timeout = HTTP_OPEN_TIMEOUT
  http.read_timeout = HTTP_READ_TIMEOUT

  retry_count = 0

  begin
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
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED => e
    retry_count += 1
    if retry_count < MAX_RETRIES
      puts "Network error (attempt #{retry_count}/#{MAX_RETRIES}): #{e.message}"
      sleep(2 ** retry_count) # Exponential backoff
      retry
    else
      raise NetworkError, "Failed to connect to CocoaPods API after #{MAX_RETRIES} attempts: #{e.message}"
    end
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
rescue NetworkError => e
  # Exit with 0 for network errors to avoid failing the workflow on transient issues
  # The workflow will simply report no updates available
  puts "Error: #{e.message}"
  puts "UPDATE_AVAILABLE=false"
  puts "Warning: Treating network error as 'no update available' to avoid failing on transient issues"
  exit 0
rescue StandardError => e
  # Exit with 1 for actual errors (e.g., parsing errors, Podfile issues)
  puts "Error: #{e.message}"
  puts "UPDATE_AVAILABLE=false"
  exit 1
end
