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
    .package(url: "https://github.com/google/gtm-session-fetcher.git", exact: "3.5.0"),
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
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLImage.xcframework.zip",
      checksum: "b2d09a93c6aee77a1c5c613d5ff356c621ecc5dbfb90e5debd1ae49c222bb740"),
    .binaryTarget(
      name: "MLKitBarcodeScanning",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitBarcodeScanning.xcframework.zip",
      checksum: "bde3632ae75d1a167b7e97427b3cec263252eb5ce2fba29ac45b3efe0bbc596e"),
    .binaryTarget(
      name: "MLKitCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitCommon.xcframework.zip",
      checksum: "180770a261c534043de3b9d81ff2b3ff0b867fedb4e06587b2715deda1b0bd7c"),
    .binaryTarget(
      name: "MLKitFaceDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitFaceDetection.xcframework.zip",
      checksum: "5089e34533f0ff73c8a6960acde038432e23c917f8d677bf53ed5f98f1757f69"),
    .binaryTarget(
      name: "MLKitVision",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitVision.xcframework.zip",
      checksum: "580a878c207afa098947b7b751ed75354dd4f422602d721f78df6a4fd60e91ac"),
    .binaryTarget(
      name: "GoogleToolboxForMac",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/GoogleToolboxForMac.xcframework.zip",
      checksum: "cae476b525ff05f2b5c126c55d1acc1cc6f068edd31e01bd3743db6d8fd8cc82"),
    .binaryTarget(
      name: "MLKitTextRecognition",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitTextRecognition.xcframework.zip",
      checksum: "8a19e27bdeb7ebbb2cebf36e3e33945815178691c604691e941ba10eff4e4db0"),
    .binaryTarget(
      name: "MLKitTextRecognitionChinese",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitTextRecognitionChinese.xcframework.zip",
      checksum: "226d5a64457e98a5a29a486c34df4f373dce5a8bddc787a02575417a82d108f0"),
    .binaryTarget(
      name: "MLKitTextRecognitionDevanagari",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitTextRecognitionDevanagari.xcframework.zip",
      checksum: "d1467eb6a8ea8192c7ef09dd564d738ba62aad8c3741f5ce7e2ad53fd7857f82"),
    .binaryTarget(
      name: "MLKitTextRecognitionJapanese",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitTextRecognitionJapanese.xcframework.zip",
      checksum: "20824fc2cc78cf414b11d3d2b00fdd6525c1d874f37be68618a7b49abe745507"),
    .binaryTarget(
      name: "MLKitTextRecognitionKorean",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitTextRecognitionKorean.xcframework.zip",
      checksum: "90e4fd0604cff05277fed653d294b53220515d4bceb9aebba634a974dabd3ccd"),
    .binaryTarget(
      name: "MLKitImageLabeling",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitImageLabeling.xcframework.zip",
      checksum: "a2e0e9a5b1d61969dbedaefd1b8ff9186323e34e88c4062511abf3a3c6757122"),
    .binaryTarget(
      name: "MLKitImageLabelingCustom",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitImageLabelingCustom.xcframework.zip",
      checksum: "ead7d46116fb2e4b2628b24d28950a8c79591cc137aa0ce381f51840800132aa"),
    .binaryTarget(
      name: "MLKitObjectDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitObjectDetection.xcframework.zip",
      checksum: "7589406d7741701edc114982bc0c5613b1c5f21f49cb407d8c4f83412ac35b6a"),
    .binaryTarget(
      name: "MLKitObjectDetectionCustom",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitObjectDetectionCustom.xcframework.zip",
      checksum: "0989eed0fca769c9cde9c2f0443c9adfca6a526f854d88cbdd29b7251e34682b"),
    .binaryTarget(
      name: "MLKitPoseDetection",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitPoseDetection.xcframework.zip",
      checksum: "11fdff7e77934e791cf1ccae49d599b0cf76d0267ba0685c02121223b9e48798"),
    .binaryTarget(
      name: "MLKitPoseDetectionAccurate",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitPoseDetectionAccurate.xcframework.zip",
      checksum: "6f4b0806bb3390996afa361cfb7cb7be1db478ec6840c6cefd66443139b35d4c"),
    .binaryTarget(
      name: "MLKitSegmentationSelfie",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitSegmentationSelfie.xcframework.zip",
      checksum: "5533181cc489f9f163cba05c5a9ebffd93734ebb705f743bad2603d120650a47"),
    .binaryTarget(
      name: "MLKitLanguageID",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitLanguageID.xcframework.zip",
      checksum: "9ac1f375684b57bc03f7c93e3f9572e4b222f33365d8c647868d367000894115"),
    .binaryTarget(
      name: "MLKitTranslate",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitTranslate.xcframework.zip",
      checksum: "858a5da586e502ec539c5e9d46e36a553aa5c1a1a049f1e03cf069b3b1fe2b45"),
    .binaryTarget(
      name: "MLKitSmartReply",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitSmartReply.xcframework.zip",
      checksum: "8262f887218a81531668a45b9ee864c0aabe56e0666c977250648695752d24e1"),
    .binaryTarget(
      name: "MLKitVisionKit",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitVisionKit.xcframework.zip",
      checksum: "464f755c8f2430eaf45eca8fcc6e817f4897af9e97842acbee7d2cb29f949b45"),
    .binaryTarget(
      name: "MLKitImageLabelingCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitImageLabelingCommon.xcframework.zip",
      checksum: "2a36eeea2777f7f84e6288bad62254a3d060fb0217e5bfe87d15e955bc63acea"),
    .binaryTarget(
      name: "MLKitObjectDetectionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitObjectDetectionCommon.xcframework.zip",
      checksum: "0412fb5414e47acefa3438cb03c95161320e3dedef3308c0a1f832bbf555b314"),
    .binaryTarget(
      name: "MLKitPoseDetectionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitPoseDetectionCommon.xcframework.zip",
      checksum: "e071d4d8049ca453488189ffb7212f9a5fa5b607700187ecf37bcd93ca7ab5b6"),
    .binaryTarget(
      name: "MLKitSegmentationCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitSegmentationCommon.xcframework.zip",
      checksum: "4ae935eba6f8fa7cd13bf9b4d60b338715e78b80ab46d62aee862dfba5aab29c"),
    .binaryTarget(
      name: "MLKitTextRecognitionCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitTextRecognitionCommon.xcframework.zip",
      checksum: "0678b42b10433ba572acb285e41e4b47178f86ac5b65ef1c0cbb05bf6917c750"),
    .binaryTarget(
      name: "MLKitXenoCommon",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitXenoCommon.xcframework.zip",
      checksum: "1777bc402641be6642f2bb4286521aeec3321eefb85b1ec37b2abb75f88d256f"),
    .binaryTarget(
      name: "MLKitNaturalLanguage",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/MLKitNaturalLanguage.xcframework.zip",
      checksum: "6249e465b239a991865aab785510e3683fb0b65954a432c7733149b03e03ba84"),
    .binaryTarget(
      name: "SSZipArchive",
      url: "https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/SSZipArchive.xcframework.zip",
      checksum: "cb7a48f63572cf65a4132ceff8c7854d24c82fe30bdc92c074ddd0e19c3a1421"),
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
