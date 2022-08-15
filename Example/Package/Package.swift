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
        .product(name: "MLKitBarcodeScanning", package: "GoogleMLKitSwiftPM"),
        .product(name: "MLKitFaceDetection", package: "GoogleMLKitSwiftPM"),
      ]),
    .testTarget(
      name: "CameraTests",
      dependencies: ["Camera"]),
  ]
)
