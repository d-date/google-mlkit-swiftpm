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
    // .binaryTarget(
    //   name: "GoogleUtilitiesComponents",
    //   path: "GoogleMLKit/GoogleUtilitiesComponents.xcframework"),

    .binaryTarget(
      name: "MLImage",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/7.0.0/MLImage.xcframework.zip",
      checksum: "14a3b4903e8e604f8920236da49867a81be867410d17f6a694070a90b5a26ce6"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/7.0.0/MLKitBarcodeScanning.xcframework.zip",
      checksum: "77e01b26ff771b4fadc0af295e25cb343f0d19c9b14f856e47ee6597106c9051"),
    .binaryTarget(
      name: "MLKitCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/7.0.0/MLKitCommon.xcframework.zip",
      checksum: "7eb16e9b6ba86b7cf1dba87f6b4b2e389b29f20e92cce30b38b3dd6ef732e71f"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/7.0.0/MLKitFaceDetection.xcframework.zip",
      checksum: "9b04ab0f161d703c47c4fab99aded0ef5fb741b50f82dc87f69f0c6d5882a715"),
    .binaryTarget(
      name: "MLKitVision",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/7.0.0/MLKitVision.xcframework.zip",
      checksum: "6e81fd283ddc91acbc4556ccbcdfb7e4fc81a954c9dc309179703068aac1820e"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/7.0.0/GoogleToolboxForMac.xcframework.zip",
      checksum: "b08c68f44bf0db71fa7ff450df75beadb163c094a9f767ed8712112b1ad43730"),
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
