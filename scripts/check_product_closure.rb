#!/usr/bin/env ruby
# frozen_string_literal: true

# Verifies that every `.library` product in Package.swift links the full
# transitive set of ML Kit frameworks that pod actually needs, according to
# Podfile.lock.
#
# A SwiftPM product only links the binary targets it lists, so a missing entry
# is not caught by building the Example app -- that app depends on every
# product at once, so a framework omitted from one product is still pulled in
# by another. Consumers who adopt a single product get undefined symbols
# instead (issue #110: MLKitPoseDetectionAccurate without MLKitXenoCommon).
#
# Usage: check_product_closure.rb   (exits non-zero when a product is short)

# Non-binary dependencies that every product picks up through the `Common`
# target, either as a binary target of its own or as a SwiftPM package.
PROVIDED_BY_COMMON = %w[
  MLKitCommon
  GoogleToolboxForMac
  GoogleUtilities
  GTMSessionFetcher
  GoogleDataTransport
  nanopb
  PromisesObjC
].freeze

def uncommented(source)
  source.lines.reject { |line| line.strip.start_with?("//") }.join
end

# Pod name without its subspec or version, e.g.
# `"GoogleToolboxForMac/NSData+zlib (< 5.0, >= 4.2.1)"` -> `GoogleToolboxForMac`
def pod_name(entry)
  entry.to_s.delete('"').split(" ").first.split("/").first
end

def pod_dependencies(lockfile)
  require "yaml"

  YAML.load_file(lockfile).fetch("PODS").each_with_object({}) do |entry, graph|
    name, dependencies = entry.is_a?(Hash) ? entry.first : [entry, []]
    graph[pod_name(name)] ||= []
    graph[pod_name(name)].concat(Array(dependencies).map { |d| pod_name(d) })
  end
end

def closure(graph, root)
  seen = []
  queue = [root]

  while (pod = queue.shift)
    next if seen.include?(pod)

    seen << pod
    queue.concat(graph.fetch(pod, []))
  end

  seen
end

def binary_targets(package)
  package.scan(/\.binaryTarget\(\s*name:\s*"([^"]+)"/).flatten
end

def products(package)
  package.scan(/\.library\(\s*name:\s*"([^"]+)",\s*targets:\s*\[(.*?)\]\s*\)/m).map do |name, targets|
    [name, targets.scan(/"([^"]+)"/).flatten]
  end
end

if $PROGRAM_NAME == __FILE__
  package = uncommented(File.read("Package.swift"))
  graph = pod_dependencies("Podfile.lock")
  available = binary_targets(package)
  failures = []

  found = products(package)
  declared_count = package.scan(/\.library\(/).length
  if found.length != declared_count
    abort "read #{found.length} of #{declared_count} .library products -- " \
          "a product declaration has a shape this script cannot parse"
  end

  found.each do |name, declared|
    unless graph.key?(name)
      warn "#{name}: no pod of this name in Podfile.lock, skipping"
      next
    end

    required = closure(graph, name) - PROVIDED_BY_COMMON
    required &= available
    missing = required - declared
    extra = declared - required - ["Common"]

    if missing.empty?
      puts format("%-32s ok%s", name, extra.empty? ? "" : " (unused: #{extra.join(", ")})")
    else
      failures << name
      puts format("%-32s MISSING %s", name, missing.join(", "))
      puts format("%-32s expected targets: %s", "", (required + ["Common"]).inspect)
    end
  end

  abort "\n#{failures.length} product(s) do not link their full dependency closure" unless failures.empty?
  puts "\nAll products link their full dependency closure."
end
