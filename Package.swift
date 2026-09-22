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
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLImage.xcframework.zip",
      checksum: "c82efa4a126339b660370468581795c89f1f6c54234d8c7118d3b6f1bca21d13"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitBarcodeScanning.xcframework.zip",
      checksum: "ee1283f7670bf7f489c2f775f2f104778b44d7bdb36a7afbf80f39ec74643e59"),
    .binaryTarget(
      name: "MLKitCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitCommon.xcframework.zip",
      checksum: "b54fc36e00c1bf50ee5f19308d75423240ced914a4e7b0477dcd12fcb893f442"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitFaceDetection.xcframework.zip",
      checksum: "2d14db31edf94275fae2268d257e0ad3620f23db272da011a0f0d46a8252c843"),
    .binaryTarget(
      name: "MLKitVision",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitVision.xcframework.zip",
      checksum: "99747eb79a2a0362846d03d2026d297bbb12b5d274cbf820b974b1f66b2a0600"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/GoogleToolboxForMac.xcframework.zip",
      checksum: "4a43341460995a185544a3fc25ce5df1f8a2ee1fd01cceaa9025eb39d538c44e"),
    .binaryTarget(
      name: "MLKitTextRecognition",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitTextRecognition.xcframework.zip",
      checksum: "9515b284b80f5bbcb762caf64cc4b02679355d44eeb9ae5f845d7eaf5bbeec31"),
    .binaryTarget(
      name: "MLKitTextRecognitionChinese",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitTextRecognitionChinese.xcframework.zip",
      checksum: "131855da30a06a1913e50d282fb6dbc07e72c5df03958d735fc0b5d2942cec69"),
    .binaryTarget(
      name: "MLKitTextRecognitionDevanagari",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitTextRecognitionDevanagari.xcframework.zip",
      checksum: "37dc1439193a1a822c1bcbbf311f9bce26ea119a754da80ef04e8dc77bdbf42d"),
    .binaryTarget(
      name: "MLKitTextRecognitionJapanese",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitTextRecognitionJapanese.xcframework.zip",
      checksum: "2f6b060c9217344663f42e65987177177cf02de486ea769158030af0aec85a9e"),
    .binaryTarget(
      name: "MLKitTextRecognitionKorean",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitTextRecognitionKorean.xcframework.zip",
      checksum: "44602d069ddad09309aa8a72b978c891cec601075a212405366f789bbfcee289"),
    .binaryTarget(
      name: "MLKitImageLabeling",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitImageLabeling.xcframework.zip",
      checksum: "22d4972fb08edc92338cff6c3694bf31167d501ff7812f1bf6b5da617c24221d"),
    .binaryTarget(
      name: "MLKitImageLabelingCustom",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitImageLabelingCustom.xcframework.zip",
      checksum: "3612a50658195933fa4a55c81d06cfd85959d00cdcba549170b379f175872d81"),
    .binaryTarget(
      name: "MLKitObjectDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitObjectDetection.xcframework.zip",
      checksum: "64b5564c0978dd50b29ce3c86ec5b0770197f1251879f9ec8cd7c76821f566ea"),
    .binaryTarget(
      name: "MLKitObjectDetectionCustom",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitObjectDetectionCustom.xcframework.zip",
      checksum: "e09faf7a46750bf5eee41dc695a1dbcba103ba0f149f9705fe4ad179f3d1a468"),
    .binaryTarget(
      name: "MLKitPoseDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitPoseDetection.xcframework.zip",
      checksum: "ad400c4e32ac1c95b87a2d4db4552a4218d0db7ff9926232fa555e1ba92ee975"),
    .binaryTarget(
      name: "MLKitPoseDetectionAccurate",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitPoseDetectionAccurate.xcframework.zip",
      checksum: "0d9e7baab1456c4bd024b569afe5a4a1a21f0abb957977f916805fc6960abfa5"),
    .binaryTarget(
      name: "MLKitSegmentationSelfie",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitSegmentationSelfie.xcframework.zip",
      checksum: "d98868c1e9c77f005d14e3da35aca026fd17dab7d10240fd1c473eb9d71df115"),
    .binaryTarget(
      name: "MLKitLanguageID",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitLanguageID.xcframework.zip",
      checksum: "c4baf33a08eacf8040e2eb5afd82425d47188aa470335b4339d264129e3c748a"),
    .binaryTarget(
      name: "MLKitTranslate",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitTranslate.xcframework.zip",
      checksum: "53c535b7a71327218083ab740e8fd9e961db255f4ed6ca2d99233ceb1280c8cc"),
    .binaryTarget(
      name: "MLKitSmartReply",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitSmartReply.xcframework.zip",
      checksum: "0e3f65dbbf4dd9cdbe6a41aed658db8261dae9970e1a55c68169da22df686f69"),
    .binaryTarget(
      name: "MLKitVisionKit",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitVisionKit.xcframework.zip",
      checksum: "933ee28008ebeb6551e10e65397f1298ffe32fd50cfb1e7ec8d568557511e3fa"),
    .binaryTarget(
      name: "MLKitImageLabelingCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitImageLabelingCommon.xcframework.zip",
      checksum: "c390c4f4538cc3562c3d37058681dd6d4760f1cabfa80edb0e7a1fedcac799cf"),
    .binaryTarget(
      name: "MLKitObjectDetectionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitObjectDetectionCommon.xcframework.zip",
      checksum: "10c14a4141b167352f0b23bbfbca8080ebedae05b178f0163ba7ed343c2ebe26"),
    .binaryTarget(
      name: "MLKitPoseDetectionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitPoseDetectionCommon.xcframework.zip",
      checksum: "08f264598ec23a886718957ff25fb3a78bb21cb30a0f17e75fc7acdecce95938"),
    .binaryTarget(
      name: "MLKitSegmentationCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitSegmentationCommon.xcframework.zip",
      checksum: "195ef0070c4e5b363e5d7bd4a10528af62de41638be0fe68f894ad3913f8e9fb"),
    .binaryTarget(
      name: "MLKitTextRecognitionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitTextRecognitionCommon.xcframework.zip",
      checksum: "5296031ab6de07de8056863b27d5f0205df9929ca98765e03a120e05c4e735b8"),
    .binaryTarget(
      name: "MLKitXenoCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitXenoCommon.xcframework.zip",
      checksum: "521e6d9b77709cb6f392867c80e3f14fc51c46aa45dd7663d523d45e2bb4dc28"),
    .binaryTarget(
      name: "MLKitNaturalLanguage",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/MLKitNaturalLanguage.xcframework.zip",
      checksum: "8063ef3eaab9fdd2efdc42bfa35f4a544c344f67bddf57cfadee701f73bd841b"),
    .binaryTarget(
      name: "SSZipArchive",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.1/SSZipArchive.xcframework.zip",
      checksum: "da0ea73662416c4b574fd242993deb1349e3d8581d1e029e9dd921699cf8939c"),
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
