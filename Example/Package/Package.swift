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
    .package(path: "../../")
  ],
  targets: [
    .target(
      name: "Camera",
      dependencies: [
        .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitFaceDetection", package: "google-mlkit-swiftpm"),
      ]),
    .testTarget(
      name: "CameraTests",
      dependencies: ["Camera"]),
  ]
)
