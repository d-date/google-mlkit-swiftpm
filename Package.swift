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
      name: "MLKitDigitalInkRecognition",
      targets: ["MLKitDigitalInkRecognition", "MLKitMDD", "SSZipArchive", "Common"]),
    .library(
      name: "MLKitEntityExtraction",
      targets: ["MLKitEntityExtraction", "MLKitNaturalLanguage", "Common"]),
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
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLImage.xcframework.zip",
      checksum: "9e206e2b1a7bd5e5c788fa3221616e61f8e9c1c1d0c12b9e81f20a24f3732103"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitBarcodeScanning.xcframework.zip",
      checksum: "908da2e7448889be44d19b3476d02accca525d51a5d54d332c474cb23bce1cb4"),
    .binaryTarget(
      name: "MLKitCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitCommon.xcframework.zip",
      checksum: "87456955b5a61d2f8a68a12290d77a00ab1b679dfb0192785b94e53a0f8d0a3d"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitFaceDetection.xcframework.zip",
      checksum: "4420f6712283c52941e7a0145356fe9a36bf9a572e30b5d615e2dc59ffcf94f8"),
    .binaryTarget(
      name: "MLKitVision",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitVision.xcframework.zip",
      checksum: "408a454ced451696ca2c98479c2db12d284b404a5d7daeeeffc6ac1dfb28942e"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/GoogleToolboxForMac.xcframework.zip",
      checksum: "4e541c66b63f85ee3d7556cd505db041fe62784e680296de50cbaf92725965cd"),
    .binaryTarget(
      name: "MLKitTextRecognition",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitTextRecognition.xcframework.zip",
      checksum: "6703514a50c2e67c70c3420c6d820bc3d826936f227bb3f9079d5070819bd6dc"),
    .binaryTarget(
      name: "MLKitTextRecognitionChinese",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitTextRecognitionChinese.xcframework.zip",
      checksum: "9d273b9d26b79d0a53ccd69c4b19bbdcbeec71172b45ffe7aa6c14a02f375658"),
    .binaryTarget(
      name: "MLKitTextRecognitionDevanagari",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitTextRecognitionDevanagari.xcframework.zip",
      checksum: "b59c31e430ec3551a4ee5cd9f1e64f11193680d4cbb9ea2995240fea9410ae62"),
    .binaryTarget(
      name: "MLKitTextRecognitionJapanese",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitTextRecognitionJapanese.xcframework.zip",
      checksum: "59e45c2dcc1c6d122f887d1d712ea805f7a9e3b9c1e958d68344cdc330f10458"),
    .binaryTarget(
      name: "MLKitTextRecognitionKorean",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitTextRecognitionKorean.xcframework.zip",
      checksum: "e285a1ae238fbad2654323837d0a74c2774c8f930e424609b03b8769f69fcdf4"),
    .binaryTarget(
      name: "MLKitImageLabeling",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitImageLabeling.xcframework.zip",
      checksum: "2d420c9ef5391a76eaa55252244f86ac28853ed9584788594a9fcfe377cb4b81"),
    .binaryTarget(
      name: "MLKitImageLabelingCustom",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitImageLabelingCustom.xcframework.zip",
      checksum: "1a9c1892486cb472711e26a2c4e1c8f0d879eb9cdf52ac99066cab6809ca475b"),
    .binaryTarget(
      name: "MLKitObjectDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitObjectDetection.xcframework.zip",
      checksum: "7bcddb81537e528f1c2c27d26653e5e3567c8579293810ad4f204f417533367c"),
    .binaryTarget(
      name: "MLKitObjectDetectionCustom",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitObjectDetectionCustom.xcframework.zip",
      checksum: "68c118222e5d6adf3b20669c1af2d111a95b1652c438b112849ae2341fb5c0c9"),
    .binaryTarget(
      name: "MLKitPoseDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitPoseDetection.xcframework.zip",
      checksum: "04751fa0d9919ddaed86876baf6c89618f50e448ddfcecaf6e5bd3b0dd645461"),
    .binaryTarget(
      name: "MLKitPoseDetectionAccurate",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitPoseDetectionAccurate.xcframework.zip",
      checksum: "b5ff4bf3947733f28538ac23d7e8e23fdfdc5c2c585379ce7a58a62f44cfa8b6"),
    .binaryTarget(
      name: "MLKitSegmentationSelfie",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitSegmentationSelfie.xcframework.zip",
      checksum: "29c3a323cc1e53db56c2bbfb8c84dc53dce499cc248c9a38d60497fc87be7c52"),
    .binaryTarget(
      name: "MLKitLanguageID",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitLanguageID.xcframework.zip",
      checksum: "1bf2fed0e3513eedacd0edae8560c6abebfce8baa4d95c349170d213d2f4c25d"),
    .binaryTarget(
      name: "MLKitTranslate",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitTranslate.xcframework.zip",
      checksum: "8cb621486b01b5a55295b0236e3aece107e7624a7d15c1dd67e62e99d35eecdb"),
    .binaryTarget(
      name: "MLKitSmartReply",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitSmartReply.xcframework.zip",
      checksum: "56936cf6316b6331e4f65f12dc51a6141a95240235e70008d653479549c88fd6"),
    .binaryTarget(
      name: "MLKitVisionKit",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitVisionKit.xcframework.zip",
      checksum: "0947e5126d779a503430929b7a51a0e172af4910d5cd3040673104284cd0cd0c"),
    .binaryTarget(
      name: "MLKitImageLabelingCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitImageLabelingCommon.xcframework.zip",
      checksum: "6bcbde271617deb2f2cc38de5505266cf128ce07e909b1f8dc7e4effd85891f5"),
    .binaryTarget(
      name: "MLKitObjectDetectionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitObjectDetectionCommon.xcframework.zip",
      checksum: "3a7172b620bb51d3d210707618b517d883c65e1b7e42f495eccae46398e8be95"),
    .binaryTarget(
      name: "MLKitPoseDetectionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitPoseDetectionCommon.xcframework.zip",
      checksum: "733f72d697cb5c584484d6efff083690373986810ba0bc83ddb97110386857ab"),
    .binaryTarget(
      name: "MLKitSegmentationCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitSegmentationCommon.xcframework.zip",
      checksum: "61689e13986032d6120d7c296f6fdc58983db83f98867356f59f52c0b17c884c"),
    .binaryTarget(
      name: "MLKitTextRecognitionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitTextRecognitionCommon.xcframework.zip",
      checksum: "66e1d343be1d253faf282d9293c29d25c68ac70278b9d9670719c9a29602ecb3"),
    .binaryTarget(
      name: "MLKitXenoCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitXenoCommon.xcframework.zip",
      checksum: "46852be00814d9b6d66cccefaa7957e41c2bb29c3471adbf21e56ef44fe52e25"),
    .binaryTarget(
      name: "MLKitDigitalInkRecognition",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitDigitalInkRecognition.xcframework.zip",
      checksum: "03558dade9ced0ca85e65d5134ebd2b37df4bbc22ba45e2703672b854c9d8e39"),
    .binaryTarget(
      name: "MLKitEntityExtraction",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitEntityExtraction.xcframework.zip",
      checksum: "0baffe8bb32d306b3177a3f39cfa14e62c8c6ad9bff00803536cc4fbfa75eb42"),
    .binaryTarget(
      name: "MLKitMDD",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitMDD.xcframework.zip",
      checksum: "89842f863a85470ae77d8bcfc944d1635ecf1e45e49d34a4901a62a57811d703"),
    .binaryTarget(
      name: "MLKitNaturalLanguage",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/MLKitNaturalLanguage.xcframework.zip",
      checksum: "7c1e1b378281f814a053283b8d470b40eb0c95405fc1227dac3f279424fc3c0a"),
    .binaryTarget(
      name: "SSZipArchive",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/SSZipArchive.xcframework.zip",
      checksum: "1529d7e0dbd1e9ace91618f79698b58ba7a54ea98c49b1936c11fa946e8669a2"),
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
