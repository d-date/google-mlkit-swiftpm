#!/usr/bin/env swift
// Compares the latest GoogleMLKit on the CocoaPods Trunk API with the
// requirement in Podfile.swift and prints UPDATE_AVAILABLE=true|false (and
// NEW_VERSION=<version> when there is one) for the check-mlkit-updates workflow.
//
// Network failures print UPDATE_AVAILABLE=false and exit 0 so a transient
// outage does not fail the scheduled workflow; anything else exits 1.
//
// Usage: swift scripts/check_mlkit_version.swift

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking  // URLSession on Linux
#endif

let environment = ProcessInfo.processInfo.environment
let maxRetries = environment["MLKIT_MAX_RETRIES"].flatMap(Int.init) ?? 3
let timeout = environment["MLKIT_HTTP_TIMEOUT"].flatMap(TimeInterval.init) ?? 30

struct NetworkError: Error { let message: String }
struct CheckError: Error { let message: String }

/// Numeric release versions only ("9.0.0"); pre-releases and odd tags are ignored.
func components(_ version: String) -> [Int]? {
    let parts = version.split(separator: ".").map { Int($0) }
    return parts.isEmpty || parts.contains(nil) ? nil : parts.map { $0! }
}

func isNewer(_ lhs: [Int], than rhs: [Int]) -> Bool {
    for index in 0 ..< max(lhs.count, rhs.count) {
        let (left, right) = (index < lhs.count ? lhs[index] : 0, index < rhs.count ? rhs[index] : 0)
        if left != right { return left > right }
    }
    return false
}

func currentVersion() throws -> String {
    guard let podfile = try? String(contentsOfFile: "Podfile.swift", encoding: .utf8),
          let match = podfile.firstMatch(of: #/\.pod\(name:\s*"GoogleMLKit/BarcodeScanning",\s*"~>\s*([0-9.]+)"\)/#)
    else { throw CheckError(message: "Could not parse version from Podfile.swift") }
    return String(match.output.1)
}

func latestVersion() async throws -> String {
    var request = URLRequest(url: URL(string: "https://trunk.cocoapods.org/api/v1/pods/GoogleMLKit")!)
    request.timeoutInterval = timeout
    var attempt = 0
    while true {
        attempt += 1
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200 ..< 300).contains(status) else {
                throw CheckError(message: "Failed to fetch MLKit version info: HTTP \(status)")
            }
            // Malformed JSON is a bad response, not a crash: report it like any other check error.
            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                  let versions = json["versions"] as? [[String: Any]]
            else { throw CheckError(message: "Unexpected response from the CocoaPods Trunk API") }
            let latest = versions.compactMap { $0["name"] as? String }
                .compactMap { name in components(name).map { (name, $0) } }
                .max { isNewer($1.1, than: $0.1) }
            guard let latest else { throw CheckError(message: "No GoogleMLKit releases found") }
            return latest.0
        } catch let error as URLError {
            guard attempt < maxRetries else {
                throw NetworkError(message: "Failed to connect to CocoaPods API after \(maxRetries) attempts: \(error.localizedDescription)")
            }
            print("Network error (attempt \(attempt)/\(maxRetries)): \(error.localizedDescription)")
            try await Task.sleep(for: .seconds(1 << attempt))  // Exponential backoff
        }
    }
}

do {
    let current = try currentVersion()
    let latest = try await latestVersion()
    print("Current version: \(current)")
    print("Latest version: \(latest)")
    if let currentParts = components(current), let latestParts = components(latest), isNewer(latestParts, than: currentParts) {
        print("New version available: \(latest)")
        print("UPDATE_AVAILABLE=true")
        print("NEW_VERSION=\(latest)")
    } else {
        print("Already up to date")
        print("UPDATE_AVAILABLE=false")
    }
} catch let error as NetworkError {
    print("Error: \(error.message)")
    print("UPDATE_AVAILABLE=false")
    print("Warning: Treating network error as 'no update available' to avoid failing on transient issues")
} catch {
    // Anything else is a real failure; still print the line the workflow parses.
    print("Error: \((error as? CheckError)?.message ?? String(describing: error))")
    print("UPDATE_AVAILABLE=false")
    exit(1)
}
