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
      targets: ["MLKitImageLabeling", "MLKitImageLabelingCommon", "MLKitVisionKit", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitImageLabelingCustom",
      targets: ["MLKitImageLabelingCustom", "MLKitImageLabelingCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitObjectDetection",
      targets: ["MLKitObjectDetection", "MLKitObjectDetectionCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitObjectDetectionCustom",
      targets: ["MLKitObjectDetectionCustom", "MLKitObjectDetectionCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitPoseDetection",
      targets: ["MLKitPoseDetection", "MLKitPoseDetectionCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitPoseDetectionAccurate",
      targets: ["MLKitPoseDetectionAccurate", "MLKitPoseDetectionCommon", "MLImage", "MLKitVision", "Common"]),
    .library(
      name: "MLKitSegmentationSelfie",
      targets: ["MLKitSegmentationSelfie", "MLKitSegmentationCommon", "MLImage", "MLKitVision", "Common"]),
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
    .package(url: "https://github.com/google/promises.git", exact: "2.4.0"),
    .package(url: "https://github.com/google/GoogleDataTransport.git", exact: "10.1.0"),
    .package(url: "https://github.com/google/GoogleUtilities.git", exact: "8.1.0"),
    .package(url: "https://github.com/google/gtm-session-fetcher.git", exact: "5.3.1"),
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
    //   name: "MLKitTextRecognition",
    //   path: "GoogleMLKit/MLKitTextRecognition.xcframework"),
    // .binaryTarget(
    //   name: "MLKitTextRecognitionChinese",
    //   path: "GoogleMLKit/MLKitTextRecognitionChinese.xcframework"),
    // .binaryTarget(
    //   name: "MLKitTextRecognitionDevanagari",
    //   path: "GoogleMLKit/MLKitTextRecognitionDevanagari.xcframework"),
    // .binaryTarget(
    //   name: "MLKitTextRecognitionJapanese",
    //   path: "GoogleMLKit/MLKitTextRecognitionJapanese.xcframework"),
    // .binaryTarget(
    //   name: "MLKitTextRecognitionKorean",
    //   path: "GoogleMLKit/MLKitTextRecognitionKorean.xcframework"),
    // .binaryTarget(
    //   name: "MLKitImageLabeling",
    //   path: "GoogleMLKit/MLKitImageLabeling.xcframework"),
    // .binaryTarget(
    //   name: "MLKitImageLabelingCustom",
    //   path: "GoogleMLKit/MLKitImageLabelingCustom.xcframework"),
    // .binaryTarget(
    //   name: "MLKitObjectDetection",
    //   path: "GoogleMLKit/MLKitObjectDetection.xcframework"),
    // .binaryTarget(
    //   name: "MLKitObjectDetectionCustom",
    //   path: "GoogleMLKit/MLKitObjectDetectionCustom.xcframework"),
    // .binaryTarget(
    //   name: "MLKitPoseDetection",
    //   path: "GoogleMLKit/MLKitPoseDetection.xcframework"),
    // .binaryTarget(
    //   name: "MLKitPoseDetectionAccurate",
    //   path: "GoogleMLKit/MLKitPoseDetectionAccurate.xcframework"),
    // .binaryTarget(
    //   name: "MLKitSegmentationSelfie",
    //   path: "GoogleMLKit/MLKitSegmentationSelfie.xcframework"),
    // .binaryTarget(
    //   name: "MLKitLanguageID",
    //   path: "GoogleMLKit/MLKitLanguageID.xcframework"),
    // .binaryTarget(
    //   name: "MLKitTranslate",
    //   path: "GoogleMLKit/MLKitTranslate.xcframework"),
    // .binaryTarget(
    //   name: "MLKitSmartReply",
    //   path: "GoogleMLKit/MLKitSmartReply.xcframework"),

    .binaryTarget(
      name: "MLImage",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLImage.xcframework.zip",
      checksum: "ed3a23f4f5bf4c1f461337311a29dd12a3d01676dd49ea06b9b21cab223159f5"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitBarcodeScanning.xcframework.zip",
      checksum: "2c0dc1ba1ec88b00e162b681a8041aee668a5d4e9c5742702d83e068365dffc7"),
    .binaryTarget(
      name: "MLKitCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitCommon.xcframework.zip",
      checksum: "0c3523adc6248b5fd7e71c5af1c3e028a2ffcd20ca6add03283e20a09740f43f"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitFaceDetection.xcframework.zip",
      checksum: "1289ed39d991ebacca543d241d971b76da5e266a18550d6d8c79d6adb3d65dd1"),
    .binaryTarget(
      name: "MLKitVision",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitVision.xcframework.zip",
      checksum: "b26f8c96d1e12515b990fca0b2237d60363d7bddc925d5ec61d7ee7d8b5e83c3"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/GoogleToolboxForMac.xcframework.zip",
      checksum: "c095707fd64bad2f36cd9bcc86251de6aab7197d5b35112f3cdf40c6c94a6b4b"),
    .binaryTarget(
      name: "MLKitTextRecognition",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitTextRecognition.xcframework.zip",
      checksum: "1f20493b54611a251cae278fd9f206c3009eee3de7091e5e4f1cb1a050526f72"),
    .binaryTarget(
      name: "MLKitTextRecognitionChinese",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitTextRecognitionChinese.xcframework.zip",
      checksum: "f0aeb7b941e2959a77f731c3ce70acb7785786d5d26ac6b4fad8d01c63488b6a"),
    .binaryTarget(
      name: "MLKitTextRecognitionDevanagari",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitTextRecognitionDevanagari.xcframework.zip",
      checksum: "5da9d3f535e6d9a98ef2d6763a8d929dd93cb62661c227db9fc41d97ac59a5c3"),
    .binaryTarget(
      name: "MLKitTextRecognitionJapanese",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitTextRecognitionJapanese.xcframework.zip",
      checksum: "d34d2ac7d7972fe34a8fbb2618ed136308664cfa0cbc1fefa82f749c79c0077c"),
    .binaryTarget(
      name: "MLKitTextRecognitionKorean",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitTextRecognitionKorean.xcframework.zip",
      checksum: "5d71b38dd27c3cf18c9b39731b53c221e8ba90a4ce9310eb78df6df95ce9a3f0"),
    .binaryTarget(
      name: "MLKitImageLabeling",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitImageLabeling.xcframework.zip",
      checksum: "e3a35c622d10f15a5281d50365120e224df4c2e7432ba9421897adff653eb16e"),
    .binaryTarget(
      name: "MLKitImageLabelingCustom",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitImageLabelingCustom.xcframework.zip",
      checksum: "fbfb8ae9ae9d1b37f4fce4be32f13758a4a5286890e25cdce5017c6460d9251b"),
    .binaryTarget(
      name: "MLKitObjectDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitObjectDetection.xcframework.zip",
      checksum: "6d94f0ebd76a646280dced879b6a35f28a26e180e72fbe37dd92355da98ccd81"),
    .binaryTarget(
      name: "MLKitObjectDetectionCustom",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitObjectDetectionCustom.xcframework.zip",
      checksum: "1fab22a0f221aee8f07a4f22cb528d6d9999d0481d7da53a3530941d8c1fe030"),
    .binaryTarget(
      name: "MLKitPoseDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitPoseDetection.xcframework.zip",
      checksum: "aeab7f89136872e2fa390b7b211713e0226b4c8f04ac60525b28e68248423ff9"),
    .binaryTarget(
      name: "MLKitPoseDetectionAccurate",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitPoseDetectionAccurate.xcframework.zip",
      checksum: "0ea9fc54a6dbf37779c85e597be30e079269cea949f8529167b22bfa35f0eced"),
    .binaryTarget(
      name: "MLKitSegmentationSelfie",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitSegmentationSelfie.xcframework.zip",
      checksum: "b8df4092fa8795e6d70386fcafa0d84fe0e220f1a2239c4c9ea611a5da95d2d4"),
    .binaryTarget(
      name: "MLKitLanguageID",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitLanguageID.xcframework.zip",
      checksum: "565a73c87c965959fc34ae989b7f97acb8134ad9cc25acd4a179f45d71b08a95"),
    .binaryTarget(
      name: "MLKitTranslate",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitTranslate.xcframework.zip",
      checksum: "b08ce5354133185c5fc4f0e64dfda1e437c23f815734b40c08832ea8db4bcf11"),
    .binaryTarget(
      name: "MLKitSmartReply",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitSmartReply.xcframework.zip",
      checksum: "a1fe1e9c2ad5bde38bace6d64367cbdbed3a48d373e9493c8a91b907b637fda4"),
    .binaryTarget(
      name: "MLKitVisionKit",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitVisionKit.xcframework.zip",
      checksum: "f46c5c0faa1d90221973044e8439f83ac767db2a960a811d2a458193ee1815b3"),
    .binaryTarget(
      name: "MLKitImageLabelingCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitImageLabelingCommon.xcframework.zip",
      checksum: "03cd40ff3b2fe0e88b6c3bf9267f74b24bc650ea9b6eac35ea3dfecd27773520"),
    .binaryTarget(
      name: "MLKitObjectDetectionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitObjectDetectionCommon.xcframework.zip",
      checksum: "a219b6169148ef66fc4c92457aee2f688e5dca83543ed7858ac987ba4386eea9"),
    .binaryTarget(
      name: "MLKitPoseDetectionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitPoseDetectionCommon.xcframework.zip",
      checksum: "53af32663e2336c5edb59292ee46667196e9dbfa193d59ece643a46d9ffc1b78"),
    .binaryTarget(
      name: "MLKitSegmentationCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitSegmentationCommon.xcframework.zip",
      checksum: "38ba81503e8db531931e5ca0e0694aa86108ff056faca403bed35854f53cc65b"),
    .binaryTarget(
      name: "MLKitTextRecognitionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitTextRecognitionCommon.xcframework.zip",
      checksum: "9b6cbfd695e5458e5ccab905d2c6a641cd29fe60a6ec4fd8acb62ef9b8ac91e7"),
    .binaryTarget(
      name: "MLKitXenoCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitXenoCommon.xcframework.zip",
      checksum: "34ee8e96f9aba5e1d9394935c3db2e255534b2bf45c883c38a011637b7e08653"),
    .binaryTarget(
      name: "MLKitNaturalLanguage",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/MLKitNaturalLanguage.xcframework.zip",
      checksum: "55da788e46e3e2aa3e409da5a50db01c292a67ca84199039f81a46e80397d026"),
    .binaryTarget(
      name: "SSZipArchive",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1/SSZipArchive.xcframework.zip",
      checksum: "5b179e6e8df6ef5d5b530e7d35e5e57503388db336a8050eca8e517e308a78be"),
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
