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
    .package(url: "https://github.com/google/GoogleUtilities.git", exact: "7.13.0"),
    .package(url: "https://github.com/google/gtm-session-fetcher.git", exact: "3.3.2"),
    .package(url: "https://github.com/firebase/nanopb.git", exact: "2.30910.0"),
  ],
  targets: [
    .binaryTarget(
      name: "MLImage",
      path: "GoogleMLKit/MLImage.xcframework"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      path: "GoogleMLKit/MLKitBarcodeScanning.xcframework"),
    .binaryTarget(
      name: "MLKitCommon",
      path: "GoogleMLKit/MLKitCommon.xcframework"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      path: "GoogleMLKit/MLKitFaceDetection.xcframework"),
    .binaryTarget(
      name: "MLKitVision",
      path: "GoogleMLKit/MLKitVision.xcframework"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      path: "GoogleMLKit/GoogleToolboxForMac.xcframework"),
    .binaryTarget(
      name: "GoogleUtilitiesComponents",
      path: "GoogleMLKit/GoogleUtilitiesComponents.xcframework"),

//    .binaryTarget(
//      name: "MLImage",
//      url:
//        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0-alpha/MLImage.xcframework.zip",
//      checksum: "a8246619639b6a7190fb4f5dbd81645dfefb7a187d23b5d22e68d1d7e1b52c2b"),
//    .binaryTarget(
//      name: "MLKitBarcodeScanning",
//      url:
//        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0-alpha/MLKitBarcodeScanning.xcframework.zip",
//      checksum: "93feb0616820b20d306f23fdede4a9a465146ec37ad5305678effe91e3e86960"),
//    .binaryTarget(
//      name: "MLKitCommon",
//      url:
//        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0-alpha/MLKitCommon.xcframework.zip",
//      checksum: "a6dba69d3bcb55b7996af8b062039469590873c1eb80f884d376d5d87890ed21"),
//    .binaryTarget(
//      name: "MLKitFaceDetection",
//      url:
//        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0-alpha/MLKitFaceDetection.xcframework.zip",
//      checksum: "036baf1a055708972cf5ce86e669e14f10a663fa567c2d42158c0ba41c10713e"),
//    .binaryTarget(
//      name: "MLKitVision",
//      url:
//        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0-alpha/MLKitVision.xcframework.zip",
//      checksum: "0976c2736e128108b52b40751ee4705f0519e629569e473760805bf24b656315"),
//    .binaryTarget(
//      name: "GoogleToolboxForMac",
//      url:
//        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0-alpha/GoogleToolboxForMac.xcframework.zip",
//      checksum: "dd6d6e72f9c21f241e51a6641ce6ff7073fabad8cfa38cd689b337e49b7641bb"),
//    .binaryTarget(
//      name: "GoogleUtilitiesComponents",
//      url:
//        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0-alpha/GoogleUtilitiesComponents.xcframework.zip",
//      checksum: "971497f6ed6681d0f0413e902731d9b9ddff26d54fd109866a7cff1917160110"),
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
