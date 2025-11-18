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
    .package(url: "https://github.com/google/GoogleDataTransport.git", exact: "10.1.0"),
    .package(url: "https://github.com/google/GoogleUtilities.git", exact: "8.1.0"),
    .package(url: "https://github.com/google/gtm-session-fetcher.git", exact: "3.5.0"),
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

    .binaryTarget(
      name: "MLImage",
      url:
        "https://github.com/iamgirya/google-mlkit-swiftpm/releases/download/7.0.0/MLImage.xcframework.zip",
      checksum: "fb6260e0ca36f64766df6a2b7d1000740914b0f00639b3957b30d5fbff21fa83"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url:
        "https://github.com/iamgirya/google-mlkit-swiftpm/releases/download/7.0.0/MLKitBarcodeScanning.xcframework.zip",
      checksum: "aa262a36ee483d6ed0c146c3722dcaa9681f336388a3ab8b173ed3a6253feb75"),
    .binaryTarget(
      name: "MLKitCommon",
      url:
        "https://github.com/iamgirya/google-mlkit-swiftpm/releases/download/7.0.0/MLKitCommon.xcframework.zip",
      checksum: "75ae1299705889647b98fb651e2d7d7efac54a5e73cb8aa13abd250260b4bb28"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url:
        "https://github.com/iamgirya/google-mlkit-swiftpm/releases/download/7.0.0/MLKitFaceDetection.xcframework.zip",
      checksum: "3ba3c41313016751448fad5de63cf368f38f26b830b008f7637aacc616d93472"),
    .binaryTarget(
      name: "MLKitVision",
      url:
        "https://github.com/iamgirya/google-mlkit-swiftpm/releases/download/7.0.0/MLKitVision.xcframework.zip",
      checksum: "5bd251aec6daf4dc6d934b583a0cb20be21129e0ea499e29db6dfdb305b7aef7"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url:
        "https://github.com/iamgirya/google-mlkit-swiftpm/releases/download/7.0.0/GoogleToolboxForMac.xcframework.zip",
      checksum: "e3ede608f8e685887ccc07aad27fb1c225843667b98755c64809587ce4188fb0"),
    .target(
      name: "Common",
      dependencies: [
        "MLKitCommon",
        "GoogleToolboxForMac",
        .product(name: "GULAppDelegateSwizzler", package: "GoogleUtilities"),
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
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
