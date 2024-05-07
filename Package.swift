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
    .package(url: "https://github.com/google/GoogleUtilities.git", exact: "7.13.1"),
    .package(url: "https://github.com/google/gtm-session-fetcher.git", exact: "3.3.2"),
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
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/MLImage.xcframework.zip",
      checksum: "597265ea8e5564c75395648a4a17a04ea13580b72ad3e89a54e421e270a80aa2"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/MLKitBarcodeScanning.xcframework.zip",
      checksum: "154dee7e26c9ca03a64ed9d849580ab66363a83c39129d251fbb8c4e9f1aeb32"),
    .binaryTarget(
      name: "MLKitCommon",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/MLKitCommon.xcframework.zip",
      checksum: "c76791cf2f6c2dd358006feb85244d4ba482c148efcdd2d299309c7429957c94"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/MLKitFaceDetection.xcframework.zip",
      checksum: "72143f113edad9b74a8aa0e3981936f81ff201cf8b008e072d1f0c57d9001bbb"),
    .binaryTarget(
      name: "MLKitVision",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/MLKitVision.xcframework.zip",
      checksum: "95ab22cca75959505e5a5be31cf10389ceaca01b66297380f4ca65f2689a5495"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/GoogleToolboxForMac.xcframework.zip",
      checksum: "5aaf5516c7449a4fc5e781d230911c191c22bd16841beacf0f838ac4d6e8ca54"),
    .binaryTarget(
      name: "GoogleUtilitiesComponents",
      url:
        "https://github.com/d-date/google-mlkit-swiftpm/releases/download/5.0.0/GoogleUtilitiesComponents.xcframework.zip",
      checksum: "d910d8266722124f18f4e1a836c6d131fef80694bf71b5e0f0554d658d026880"),
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
