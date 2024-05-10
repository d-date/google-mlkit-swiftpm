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
    .package(url: "https://github.com/google/GoogleUtilities.git", exact: "7.13.3"),
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
      checksum: "3c4a161c260d4e3014bcf3bd80febf09aef417a4b6cc4154e316ae2ac886443e"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/MLKitBarcodeScanning.xcframework.zip",
      checksum: "6514700529f77db2ad6bd899e7f5e70abccde09af9308f12c5cdcaaeb25e94fa"),
    .binaryTarget(
      name: "MLKitCommon",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/MLKitCommon.xcframework.zip",
      checksum: "5917182923f1ca880b79c8b00c4e7b19f4192ce204c1ab62289f35c47074f239"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/MLKitFaceDetection.xcframework.zip",
      checksum: "ac631f0190fec98a6595a299f2ded4a107cb3ef5febeffebd70aa7ab50d1d812"),
    .binaryTarget(
      name: "MLKitVision",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/MLKitVision.xcframework.zip",
      checksum: "583d90ede764dedaf38f9422f804beed9b4bd006f5d4d6f9738a0cfaca00b60c"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/GoogleToolboxForMac.xcframework.zip",
      checksum: "edf443ff28f9e4c28998871d2bd11654f43de2e8e81b645ecb7de14d9d79fc96"),
    .binaryTarget(
      name: "GoogleUtilitiesComponents",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/6.0.0/GoogleUtilitiesComponents.xcframework.zip",
      checksum: "f34db62a980a77f68ee1ccb995edffdf5e68a758a521cdcd203bff5efb2d1722"),
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
