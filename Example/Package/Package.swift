// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "Example",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "Camera",
      targets: ["Camera"])
  ],
  dependencies: [
    .package(path: "../../"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "9.2.0"),
  ],
  targets: [
    .target(
      name: "Camera",
      dependencies: [
        .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitFaceDetection", package: "google-mlkit-swiftpm"),
        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
      ]),
    .testTarget(
      name: "CameraTests",
      dependencies: ["Camera"]),
  ]
)
