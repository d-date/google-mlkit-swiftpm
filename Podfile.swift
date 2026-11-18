import SwiftPodsDescription

// Builds ML Kit's pods into the binary targets of this repository's Package.swift.
// Run `swiftpods package --version <release>`; do not edit Package.swift by hand.
let podfile = Podfile(
    platform: .iOS("15.5"),
    // Static linkage keeps GoogleToolboxForMac and SSZipArchive, the only pods built
    // from source, out of the consumer app's Frameworks directory (ITMS-91065).
    useFrameworks: .static,
    installationOptions: .init(integrateTargets: false),
    packages: [
        .package(url: "https://github.com/google/promises.git", from: "2.4.0"),
        .package(url: "https://github.com/google/GoogleDataTransport.git", from: "10.1.0"),
        .package(url: "https://github.com/google/GoogleUtilities.git", from: "8.1.0"),
        .package(url: "https://github.com/google/gtm-session-fetcher.git", "3.5.0"..<"6.0.0",
                 overridingPodRequirements: .unsafe(reason: "ABI checked by hand for Firebase 13 (#124, #125)")),
        .package(url: "https://github.com/firebase/nanopb.git", "2.30910.0"..<"2.30911.0",
                 overridingPodRequirements: .unsafe(reason: "Firebase 13.1.1 requires 2.30910.1, a fork commit of the pods' 2.30910.0")),
    ],
    distribution: .init(name: "GoogleMLKitSwiftPM", url: "https://github.com/d-date/google-mlkit-swiftpm"),
    targets: [
        .target(
            name: "MLKit",
            dependencies: [
                .pod(name: "GoogleMLKit/FaceDetection", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/BarcodeScanning", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/TextRecognition", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/TextRecognitionChinese", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/TextRecognitionDevanagari", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/TextRecognitionJapanese", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/TextRecognitionKorean", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/ImageLabeling", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/ImageLabelingCustom", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/ObjectDetection", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/ObjectDetectionCustom", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/PoseDetection", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/PoseDetectionAccurate", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/SegmentationSelfie", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/DigitalInkRecognition", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/EntityExtraction", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/LanguageID", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/Translate", "~> 9.0.0"),
                .pod(name: "GoogleMLKit/SmartReply", "~> 9.0.0"),
            ]
        ),
    ]
)
