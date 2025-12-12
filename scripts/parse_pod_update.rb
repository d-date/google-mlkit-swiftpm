#!/usr/bin/env ruby
# frozen_string_literal: true

# Parse pod update output to detect component changes
# Input: pod update log (from stdin or file)
# Output: JSON with added, removed, and updated components

require 'json'

# Parse pod update log and extract changes
def parse_pod_log(log_content)
  changes = {
    added: [],
    removed: [],
    updated: []
  }

  log_content.each_line do |line|
    # Match patterns like:
    # Installing GoogleMLKit 9.0.0 (was 8.0.0)
    # Installing MLImage 1.0.0-beta8 (was 1.0.0-beta7)
    # Installing NewComponent 1.0.0
    # Removing OldComponent

    case line
    when /^Installing\s+(\S+)\s+([\d.\-\w]+)\s+\(was\s+([\d.\-\w]+)\)/
      # Component was updated
      component = $1
      new_version = $2
      old_version = $3
      changes[:updated] << {
        name: component,
        old_version: old_version,
        new_version: new_version
      }
    when /^Installing\s+(\S+)\s+([\d.\-\w]+)$/
      # New component added (no "was" clause)
      component = $1
      version = $2
      changes[:added] << {
        name: component,
        version: version
      }
    when /^Removing\s+(\S+)/
      # Component removed
      component = $1
      changes[:removed] << {
        name: component
      }
    end
  end

  changes
end

# Format changes as human-readable text
def format_changes(changes)
  output = []

  unless changes[:added].empty?
    output << "=== Added Components ==="
    changes[:added].each do |comp|
      output << "  + #{comp[:name]} #{comp[:version]}"
    end
    output << ""
  end

  unless changes[:removed].empty?
    output << "=== Removed Components ==="
    changes[:removed].each do |comp|
      output << "  - #{comp[:name]}"
    end
    output << ""
  end

  unless changes[:updated].empty?
    output << "=== Updated Components ==="
    changes[:updated].each do |comp|
      output << "  #{comp[:name]}: #{comp[:old_version]} → #{comp[:new_version]}"
    end
    output << ""
  end

  if changes[:added].empty? && changes[:removed].empty? && changes[:updated].empty?
    output << "No component changes detected."
  end

  output.join("\n")
end

# Generate summary for release notes
def generate_summary(changes)
  summary = []

  unless changes[:updated].empty?
    summary << "Updated components:"
    changes[:updated].each do |comp|
      summary << "- #{comp[:name]}: #{comp[:old_version]} → #{comp[:new_version]}"
    end
  end

  unless changes[:added].empty?
    summary << "\nAdded components:"
    changes[:added].each do |comp|
      summary << "- #{comp[:name]} #{comp[:version]}"
    end
  end

  unless changes[:removed].empty?
    summary << "\nRemoved components:"
    changes[:removed].each do |comp|
      summary << "- #{comp[:name]}"
    end
  end

  summary.join("\n")
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  # Read from file if provided, otherwise from stdin
  log_content = if ARGV[0] && File.exist?(ARGV[0])
    File.read(ARGV[0])
  elsif !STDIN.tty?
    STDIN.read
  else
    puts "Usage: #{File.basename($PROGRAM_NAME)} [log_file]"
    puts "   or: pod update | #{File.basename($PROGRAM_NAME)}"
    exit 1
  end

  changes = parse_pod_log(log_content)

  # Determine output format
  output_format = ENV['OUTPUT_FORMAT'] || 'text'

  case output_format
  when 'json'
    puts JSON.pretty_generate(changes)
  when 'summary'
    puts generate_summary(changes)
  else
    puts format_changes(changes)
  end

  # Exit with status based on whether changes were found
  exit(changes[:added].empty? && changes[:removed].empty? && changes[:updated].empty? ? 1 : 0)
end
