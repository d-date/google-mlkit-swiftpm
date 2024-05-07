// swift-tools-version: 5.9

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
    .package(url: "https://github.com/google/GoogleUtilities.git", exact: "7.13.2"),
    .package(url: "https://github.com/google/gtm-session-fetcher.git", exact: "3.4.1"),
    .package(url: "https://github.com/firebase/nanopb.git", exact: "2.30910.0"),
  ],
  targets: [
    // For debugging
    // .binaryTarget(
    //   name: "MLImage",
    //   path: "GoogleMLKit/MLImage.xcframework"),
    // .binaryTarget(
    //   name: "MLKitBarcodeScanning",
    //   path: "GoogleMLKit/MLKitBarcodeScanning.xcframework"),
    // .binaryTarget(
    //   name: "MLKitCommon",
    //   path: "GoogleMLKit/MLKitCommon.xcframework"),
    // .binaryTarget(
    //   name: "MLKitFaceDetection",
    //   path: "GoogleMLKit/MLKitFaceDetection.xcframework"),
    // .binaryTarget(
    //   name: "MLKitVision",
    //   path: "GoogleMLKit/MLKitVision.xcframework"),
    // .binaryTarget(
    //   name: "GoogleToolboxForMac",
    //   path: "GoogleMLKit/GoogleToolboxForMac.xcframework"),
    // .binaryTarget(
    //   name: "GoogleUtilitiesComponents",
    //   path: "GoogleMLKit/GoogleUtilitiesComponents.xcframework"),

    .binaryTarget(
      name: "MLImage",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/MLImage.xcframework.zip",
      checksum: "1a9b4feddbd230dfbefc6e5d249efc31261bf9fb6e7d175a4e0879aeff048ce3"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/MLKitBarcodeScanning.xcframework.zip",
      checksum: "701f8fa7bcc21c74e0f625d75f8ccc6b5c1dc1ba4ee01ee757e304f2e78fbb26"),
    .binaryTarget(
      name: "MLKitCommon",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/MLKitCommon.xcframework.zip",
      checksum: "fb680b656ee5e0326e773214aaf43cf9f3d6eccf00298bb08143ef80892cadf1"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/MLKitFaceDetection.xcframework.zip",
      checksum: "49a4416a76e3dc4a2047d1c04c6be294943cef17901a7ff1769e254fbdcc18da"),
    .binaryTarget(
      name: "MLKitVision",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/MLKitVision.xcframework.zip",
      checksum: "fbf9e1d83e99d8ff34b7b7c89b2df25b01fa3cef4240ae3cdd005118389c76dc"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/GoogleToolboxForMac.xcframework.zip",
      checksum: "60d41c3d1b47461ae427e48d0be1807b6d209f78110076c5ce1cee1aab49791c"),
    .binaryTarget(
      name: "GoogleUtilitiesComponents",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/GoogleUtilitiesComponents.xcframework.zip",
      checksum: "57a2f5368da359425fe751cff7d279e8adac83bb2e4602968f3d1c8f3b71287a"),
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
