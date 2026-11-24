#!/usr/bin/env swift
// Rewrites every `.binaryTarget` in Package.swift to point at the XCFrameworks
// that `swiftpods package` wrote to build/distribution/ instead of a GitHub
// Release asset, so the package can be built and archived before anything is
// published. Restore with `git checkout Package.swift`.
//
// Usage: swift scripts/use_local_binaries.swift [package-path] [xcframework-directory]

import Foundation

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

let arguments = CommandLine.arguments.dropFirst()
let packagePath = arguments.first ?? "Package.swift"
let directory = arguments.dropFirst().first ?? "build/distribution"

guard let source = try? String(contentsOfFile: packagePath, encoding: .utf8) else {
    fail("cannot read \(packagePath)")
}

let target = #/(?m)^( *\.binaryTarget\(\s*name: "([^"]+)",)\s*url: "[^"]*",\s*checksum: "[^"]*"\)/#
var paths: [String] = []
let rewritten = source.replacing(target) { match in
    let path = "\(directory)/\(match.output.2).xcframework"
    paths.append(path)
    return "\(match.output.1)\n      path: \"\(path)\")"
}

if paths.isEmpty { fail("no URL-based binary targets found in \(packagePath)") }

var isDirectory: ObjCBool = false
let missing = paths.filter { !FileManager.default.fileExists(atPath: $0, isDirectory: &isDirectory) || !isDirectory.boolValue }
if !missing.isEmpty { fail("missing XCFrameworks:\n  " + missing.joined(separator: "\n  ")) }

do {
    try rewritten.write(toFile: packagePath, atomically: true, encoding: .utf8)
} catch {
    fail("cannot write \(packagePath): \(error)")
}
print("Pointed \(paths.count) binary target(s) at \(directory)/")
