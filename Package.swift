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
    .package(url: "https://github.com/google/gtm-session-fetcher.git", from: "3.3.2"),
    .package(url: "https://github.com/firebase/nanopb.git", .upToNextMinor(from: "2.30910.0")),
  ],
  targets: [
    .binaryTarget(
      name: "MLImage",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/4.0.0/MLImage.xcframework.zip",
      checksum: "d360820204628a8d6d9a915d0bd9ed78aec6ed0eeed7c84c1e78bd85909bbe37"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/4.0.0/MLKitBarcodeScanning.xcframework.zip",
      checksum: "93cf8f4cbda516f0db4895e951a9430e07f8b3d44b55d2193fbd079e27d2f5fa"),
    .binaryTarget(
      name: "MLKitCommon",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/4.0.0/MLKitCommon.xcframework.zip",
      checksum: "50e1c24fc66b9a5b0516dccee5a27bca226e4f41f661799fc96873b572b51417"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/4.0.0/MLKitFaceDetection.xcframework.zip",
      checksum: "dbdc769316aa27e316a6404ee9cac847265e0ba6a164f680d10aaa192978fdfb"),
    .binaryTarget(
      name: "MLKitVision",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/4.0.0/MLKitVision.xcframework.zip",
      checksum: "19acaf1d993c6911bca9684364d47362cd8ff30ee2609f02a5f94d5143e64edb"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/4.0.0/GoogleToolboxForMac.xcframework.zip",
      checksum: "6f2e01c3fada4c9a92f45cd83374716026cb5aebf4fed1f74bdd3eba9e9d83bc"),
    .binaryTarget(
      name: "GoogleUtilitiesComponents",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/4.0.0/GoogleUtilitiesComponents.xcframework.zip",
      checksum: "e9b4e629a140234cee5f4da292219c32f3212fc1fce23c773043e10692abb14d"),
    .binaryTarget(
      name: "Protobuf",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/4.0.0/Protobuf.xcframework.zip",
      checksum: "e411598ad55b7a74bdec956e67fd7e6b453fcd4267c0f7ccfdfad0952a220cbd"),
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
