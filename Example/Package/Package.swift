// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "Example",
  platforms: [.iOS(.v26)],
  products: [
    .library(
      name: "Camera",
      targets: ["Camera"])
  ],
  dependencies: [
    .package(path: "../../"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.0.0"),
  ],
  targets: [
    .target(
      name: "Camera",
      dependencies: [
        .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitFaceDetection", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTextRecognition", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTextRecognitionChinese", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTextRecognitionDevanagari", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTextRecognitionJapanese", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTextRecognitionKorean", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitImageLabeling", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitImageLabelingCustom", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitObjectDetection", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitObjectDetectionCustom", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitPoseDetection", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitPoseDetectionAccurate", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitSegmentationSelfie", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitLanguageID", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTranslate", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitSmartReply", package: "google-mlkit-swiftpm"),
        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
      ]),
    .testTarget(
      name: "CameraTests",
      dependencies: ["Camera"]),
  ]
)
