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
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/8.0.0/MLImage.xcframework.zip",
      checksum: "b083e6b2d0a1d9a88277c8844c6a874e5d36f5a8fb3c60a8f29f0f83c96c2f39"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/8.0.0/MLKitBarcodeScanning.xcframework.zip",
      checksum: "d17997514ebf75f2fd43fb04a865baefd477e5e244cd47f64570ac34cbcfa938"),
    .binaryTarget(
      name: "MLKitCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/8.0.0/MLKitCommon.xcframework.zip",
      checksum: "0d9020d7a05dbb8c333a7b30ddffb49321378d9e58638b7f675e4fde069399b3"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/8.0.0/MLKitFaceDetection.xcframework.zip",
      checksum: "1eee92cdb0fafcac02f8e9711646c322c11d2b9de536176817ed11d9dfeffc2b"),
    .binaryTarget(
      name: "MLKitVision",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/8.0.0/MLKitVision.xcframework.zip",
      checksum: "a59abe30b1686e62f19fdf647b3d87e74dc2cf67af40e1ad93dd842e393faba9"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/8.0.0/GoogleToolboxForMac.xcframework.zip",
      checksum: "c93924c3ac7161d58d5d207590c3aecca4e23e202e8c2ebd14fddfd95862a341"),
    .target(
      name: "Common",
      dependencies: [
        "MLKitCommon",
        "GoogleToolboxForMac",
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
