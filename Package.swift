// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "GoogleMLKitSwiftPM",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "MLKitBarcodeScanning",
      targets: ["MLKitBarcodeScanning", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitFaceDetection",
      targets: ["MLKitFaceDetection", "MLImage", "MLKitVision", "Common"]),
  ],
  dependencies: [
    .package(url: "https://github.com/google/promises.git", exact: "2.4.0"),
    .package(url: "https://github.com/google/GoogleDataTransport.git", exact: "9.4.0"),
    .package(url: "https://github.com/google/GoogleUtilities.git", exact: "7.13.0"),
    .package(url: "https://github.com/google/gtm-session-fetcher.git", from: "2.3.0"),
    .package(url: "https://github.com/firebase/nanopb.git", .upToNextMinor(from: "2.30910.0")),
  ],
  targets: [
    .binaryTarget(
      name: "MLImage",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/MLImage.xcframework.zip",
      checksum: "fdb7f37e0f06e4f9e76538b6f590c5faaf5119f436300eee19f3e1fac6df8c28"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/MLKitBarcodeScanning.xcframework.zip",
      checksum: "6a71b5bab6a4327693b6773c4f87252809c591b77795b89785fc108f21c7230f"),
    .binaryTarget(
      name: "MLKitCommon",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/MLKitCommon.xcframework.zip",
      checksum: "6a03f89f6ea07d337ff76768742d3cc68d8f22ab2b13e3063e1b459767873c8d"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/MLKitFaceDetection.xcframework.zip",
      checksum: "4891acc667c8dea3916eae2b68287ba8ea42ca58d3724620ba7f0f873f443473"),
    .binaryTarget(
      name: "MLKitVision",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/MLKitVision.xcframework.zip",
      checksum: "f6267eff61383b5fd23dabd9933a8a62cb0321f2c4a6d1b20857613c68627464"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/GoogleToolboxForMac.xcframework.zip",
      checksum: "2abfacd937f3ca198751ea540e247c6c89a31830bb420a831c5db8963b26ddd1"),
    .binaryTarget(
      name: "GoogleUtilitiesComponents",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/GoogleUtilitiesComponents.xcframework.zip",
      checksum: "fb1990dc1a3b76038af056b224c25e8fae08211b8a8b42cb0dc024869ad42088"),
    .target(
      name: "Common",
      dependencies: [
        "MLKitCommon",
        "GoogleToolboxForMac",
        "GoogleUtilitiesComponents",
        .product(name: "GULAppDelegateSwizzler", package: "GoogleUtilities"),
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
        .product(name: "GULISASwizzler", package: "GoogleUtilities"),
        .product(name: "GULLogger", package: "GoogleUtilities"),
        .product(name: "GULMethodSwizzler", package: "GoogleUtilities"),
        .product(name: "GULNSData", package: "GoogleUtilities"),
        .product(name: "GULNetwork", package: "GoogleUtilities"),
        .product(name: "GULReachability", package: "GoogleUtilities"),
        .product(name: "GULUserDefaults", package: "GoogleUtilities"),
        .product(name: "GTMSessionFetcher", package: "gtm-session-fetcher"),
        .product(name: "GoogleDataTransport", package: "GoogleDataTransport"),
        .product(name: "nanopb", package: "nanopb"),
        .product(name: "FBLPromises", package: "promises"),
      ]),
  ]
)
