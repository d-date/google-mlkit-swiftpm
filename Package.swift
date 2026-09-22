// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "GoogleMLKitSwiftPM",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "MLKitBarcodeScanning",
      targets: ["MLKitBarcodeScanning", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitFaceDetection",
      targets: ["MLKitFaceDetection", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitTextRecognition",
      targets: ["MLKitTextRecognition", "MLKitTextRecognitionCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitTextRecognitionChinese",
      targets: ["MLKitTextRecognitionChinese", "MLKitTextRecognitionCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitTextRecognitionDevanagari",
      targets: ["MLKitTextRecognitionDevanagari", "MLKitTextRecognitionCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitTextRecognitionJapanese",
      targets: ["MLKitTextRecognitionJapanese", "MLKitTextRecognitionCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitTextRecognitionKorean",
      targets: ["MLKitTextRecognitionKorean", "MLKitTextRecognitionCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitImageLabeling",
      targets: ["MLKitImageLabeling", "MLKitImageLabelingCommon", "MLKitObjectDetectionCommon", "MLKitVisionKit", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitImageLabelingCustom",
      targets: ["MLKitImageLabelingCustom", "MLKitImageLabelingCommon", "MLKitObjectDetectionCommon", "MLKitVisionKit", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitObjectDetection",
      targets: ["MLKitObjectDetection", "MLKitObjectDetectionCommon", "MLKitImageLabelingCommon", "MLKitVisionKit", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitObjectDetectionCustom",
      targets: ["MLKitObjectDetectionCustom", "MLKitObjectDetectionCommon", "MLKitImageLabelingCommon", "MLKitVisionKit", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitPoseDetection",
      targets: ["MLKitPoseDetection", "MLKitPoseDetectionCommon", "MLKitXenoCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitPoseDetectionAccurate",
      targets: ["MLKitPoseDetectionAccurate", "MLKitPoseDetectionCommon", "MLKitXenoCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitSegmentationSelfie",
      targets: ["MLKitSegmentationSelfie", "MLKitSegmentationCommon", "MLKitXenoCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitLanguageID",
      targets: ["MLKitLanguageID", "MLKitNaturalLanguage", "MLKitXenoCommon", "MLKitCommon", "GoogleToolboxForMac", "Common"]),
    .library(
      name: "MLKitTranslate",
      targets: ["MLKitTranslate", "SSZipArchive", "MLKitNaturalLanguage", "MLKitXenoCommon", "MLKitCommon", "GoogleToolboxForMac", "Common"]),
    .library(
      name: "MLKitSmartReply",
      targets: ["MLKitSmartReply", "MLKitLanguageID", "MLKitNaturalLanguage", "MLKitXenoCommon", "MLKitCommon", "GoogleToolboxForMac", "Common"]),
  ],
  dependencies: [
    .package(url: "https://github.com/google/promises.git", from: "2.4.0"),
    .package(url: "https://github.com/google/GoogleDataTransport.git", from: "10.1.0"),
    .package(url: "https://github.com/google/GoogleUtilities.git", from: "8.1.0"),
    .package(url: "https://github.com/google/gtm-session-fetcher.git", from: "3.5.0"),
    .package(url: "https://github.com/firebase/nanopb.git", .upToNextMinor(from: "2.30910.0")),
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
      name: "MLKitTextRecognition",
      path: "GoogleMLKit/MLKitTextRecognition.xcframework"),
    .binaryTarget(
      name: "MLKitTextRecognitionChinese",
      path: "GoogleMLKit/MLKitTextRecognitionChinese.xcframework"),
    .binaryTarget(
      name: "MLKitTextRecognitionDevanagari",
      path: "GoogleMLKit/MLKitTextRecognitionDevanagari.xcframework"),
    .binaryTarget(
      name: "MLKitTextRecognitionJapanese",
      path: "GoogleMLKit/MLKitTextRecognitionJapanese.xcframework"),
    .binaryTarget(
      name: "MLKitTextRecognitionKorean",
      path: "GoogleMLKit/MLKitTextRecognitionKorean.xcframework"),
    .binaryTarget(
      name: "MLKitImageLabeling",
      path: "GoogleMLKit/MLKitImageLabeling.xcframework"),
    .binaryTarget(
      name: "MLKitImageLabelingCustom",
      path: "GoogleMLKit/MLKitImageLabelingCustom.xcframework"),
    .binaryTarget(
      name: "MLKitObjectDetection",
      path: "GoogleMLKit/MLKitObjectDetection.xcframework"),
    .binaryTarget(
      name: "MLKitObjectDetectionCustom",
      path: "GoogleMLKit/MLKitObjectDetectionCustom.xcframework"),
    .binaryTarget(
      name: "MLKitPoseDetection",
      path: "GoogleMLKit/MLKitPoseDetection.xcframework"),
    .binaryTarget(
      name: "MLKitPoseDetectionAccurate",
      path: "GoogleMLKit/MLKitPoseDetectionAccurate.xcframework"),
    .binaryTarget(
      name: "MLKitSegmentationSelfie",
      path: "GoogleMLKit/MLKitSegmentationSelfie.xcframework"),
    .binaryTarget(
      name: "MLKitLanguageID",
      path: "GoogleMLKit/MLKitLanguageID.xcframework"),
    .binaryTarget(
      name: "MLKitTranslate",
      path: "GoogleMLKit/MLKitTranslate.xcframework"),
    .binaryTarget(
      name: "MLKitSmartReply",
      path: "GoogleMLKit/MLKitSmartReply.xcframework"),
    .binaryTarget(
      name: "MLKitVisionKit",
      path: "GoogleMLKit/MLKitVisionKit.xcframework"),
    .binaryTarget(
      name: "MLKitImageLabelingCommon",
      path: "GoogleMLKit/MLKitImageLabelingCommon.xcframework"),
    .binaryTarget(
      name: "MLKitObjectDetectionCommon",
      path: "GoogleMLKit/MLKitObjectDetectionCommon.xcframework"),
    .binaryTarget(
      name: "MLKitPoseDetectionCommon",
      path: "GoogleMLKit/MLKitPoseDetectionCommon.xcframework"),
    .binaryTarget(
      name: "MLKitSegmentationCommon",
      path: "GoogleMLKit/MLKitSegmentationCommon.xcframework"),
    .binaryTarget(
      name: "MLKitTextRecognitionCommon",
      path: "GoogleMLKit/MLKitTextRecognitionCommon.xcframework"),
    .binaryTarget(
      name: "MLKitXenoCommon",
      path: "GoogleMLKit/MLKitXenoCommon.xcframework"),
    .binaryTarget(
      name: "MLKitNaturalLanguage",
      path: "GoogleMLKit/MLKitNaturalLanguage.xcframework"),
    .binaryTarget(
      name: "SSZipArchive",
      path: "GoogleMLKit/SSZipArchive.xcframework"),
    .target(
      name: "Common",
      dependencies: [
        "MLKitCommon",
        "GoogleToolboxForMac",
        .product(name: "GULAppDelegateSwizzler", package: "GoogleUtilities"),
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
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
