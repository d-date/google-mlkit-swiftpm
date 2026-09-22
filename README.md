# Google ML Kit for Swift Package Manager

Google ships ML Kit only through CocoaPods. This project rebuilds those pods as
XCFrameworks, publishes them as GitHub Release assets, and exposes them as 17
SwiftPM library products.

## Requirements

- iOS 15 or later
- Xcode 15 or later to consume the package; Xcode 26 or later to build it

Apple Silicon simulators are supported — see [Simulator support](#simulator-support).

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/d-date/google-mlkit-swiftpm", from: "9.0.1")
]
```

Then add the modules you need:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTextRecognition", package: "google-mlkit-swiftpm"),
    ]
)
```

Three steps are **not optional**. Skip any of them and the module fails at
runtime rather than at build time:

1. [Add the linker flags](#1-add-the-linker-flags)
2. [Add the resource bundles your modules need](#2-add-the-resource-bundles)
3. Nothing else — but read [Simulator support](#simulator-support) if you are
   coming from an older release with `EXCLUDED_ARCHS` set.

> **Upgrading from 9.0.0 or 9.0.0-1?** `9.0.1` is the same upstream ML Kit
> 9.0.0 build, repackaged. It is the first release where text recognition, pose
> detection and selfie segmentation ship their models at all, where a single
> product can be adopted without undefined symbols, where the simulator slice
> covers arm64, and where App Store Connect accepts the upload. If you set
> `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64` for an earlier release, remove it.

### 1. Add the linker flags

Add these to **Other Linker Flags** for your app target:

- `-ObjC`
- `-all_load`

ML Kit ships as static archives that register classes and models through
Objective-C categories and static initialisers. Without these flags the linker
drops the archive members that hold them, and you get `unrecognized selector`
or a model that refuses to load.

### 2. Add the resource bundles

Every ML Kit model lives in a resource bundle, and Swift Package Manager cannot
carry a resource bundle inside a binary target. Each bundle is published as a
separate release asset: download the ones your modules need, add them to your
Xcode project, and make sure they land in **Copy Bundle Resources** of your app
target.

```bash
./scripts/download_bundles.sh 9.0.1
```

| Bundle | Needed by |
| --- | --- |
| `GoogleMVFaceDetectorResources.bundle` | `MLKitFaceDetection` |
| `LatinOCRResources.bundle` | `MLKitTextRecognition` |
| `ChineseOCRResources.bundle` | `MLKitTextRecognitionChinese` |
| `DevanagariOCRResources.bundle` | `MLKitTextRecognitionDevanagari` |
| `JapaneseOCRResources.bundle` | `MLKitTextRecognitionJapanese` |
| `KoreanOCRResources.bundle` | `MLKitTextRecognitionKorean` |
| `MLKitImageLabelingResources.bundle` | `MLKitImageLabeling` |
| `MLKitObjectDetectionResources.bundle` | `MLKitObjectDetection` |
| `MLKitObjectDetectionCommonResources.bundle` | `MLKitImageLabeling`, `MLKitImageLabelingCustom`, `MLKitObjectDetection`, `MLKitObjectDetectionCustom` |
| `MLKitPoseDetectionFastResources.bundle` | `MLKitPoseDetection` |
| `MLKitPoseDetectionAccurateResources.bundle` | `MLKitPoseDetectionAccurate` |
| `MLKitPoseDetectionCommonResources.bundle` | `MLKitPoseDetection`, `MLKitPoseDetectionAccurate` |
| `MLKitSegmentationSelfieResources.bundle` | `MLKitSegmentationSelfie` |
| `MLKitSegmentationCommonResources.bundle` | `MLKitSegmentationSelfie` |
| `MLKitXenoResources.bundle` | `MLKitPoseDetection`, `MLKitPoseDetectionAccurate`, `MLKitSegmentationSelfie` |
| `MLKitTranslate_resource.bundle` | `MLKitTranslate` |
| `PredictOnDeviceResource.bundle` | `MLKitSmartReply` |

`PredictOnDevice_resource.bundle` is also published: it is the same content
under the name ML Kit nests inside its own framework, which is what releases
before 9.0.1 shipped. Add whichever your build already refers to; adding both
is harmless.

A missing bundle shows up as a runtime throw — text recognition, for example,
raises `MLKTextRecognizerInternalErrorCreationFailure` with "Invalid model
path.".

## Products

Add only the products you use; each one links just the frameworks it needs.

### Vision

| Product | What it does |
| --- | --- |
| `MLKitBarcodeScanning` | Scan and decode barcodes |
| `MLKitFaceDetection` | Detect faces, contours and facial features |
| `MLKitTextRecognition` | Recognise Latin-script text (v2) |
| `MLKitTextRecognitionChinese` | Chinese text |
| `MLKitTextRecognitionDevanagari` | Devanagari text |
| `MLKitTextRecognitionJapanese` | Japanese text |
| `MLKitTextRecognitionKorean` | Korean text |
| `MLKitImageLabeling` | Label objects, places and activities |
| `MLKitImageLabelingCustom` | Image labeling with your own model |
| `MLKitObjectDetection` | Detect and track objects |
| `MLKitObjectDetectionCustom` | Object detection with your own model |
| `MLKitPoseDetection` | Body pose detection |
| `MLKitPoseDetectionAccurate` | Body pose detection, accurate model |
| `MLKitSegmentationSelfie` | Separate people from the background |

### Language

| Product | What it does |
| --- | --- |
| `MLKitLanguageID` | Identify the language of a string |
| `MLKitTranslate` | Translate between languages on device |
| `MLKitSmartReply` | Suggest contextual replies |

## Simulator support

ML Kit's pre-built binaries contain no arm64 simulator code, and Xcode 26
dropped Rosetta simulators — so on Apple Silicon the published XCFrameworks
used to be unusable in the Simulator entirely.

Since 9.0.1 the arm64 simulator slice is synthesised from the device slice by
rewriting the Mach-O platform (`scripts/postprocess_xcframeworks.rb`).
Published XCFrameworks carry `arm64` for iphoneos and `arm64` + `x86_64` for
iphonesimulator, so no `EXCLUDED_ARCHS` workaround is needed.

## Known limitations

- **No dSYMs.** Google ships ML Kit without debug info, so Xcode's archive step
  reports "Upload Symbols Failed" for each ML Kit framework. The frameworks are
  linked statically, so their symbols end up in your app's own dSYM; the
  warnings are spurious and do not block submission. You could not symbolicate
  inside ML Kit anyway — it is closed source.
- **Resource bundles are manual.** Swift Package Manager has no way to ship
  them inside a binary target. See [above](#2-add-the-resource-bundles).
- **The wrapper version is not the pod version.** `9.0.1` repackages upstream
  ML Kit `9.0.0`; the pod versions each framework reports are Google's own.

## Example app

```bash
git submodule update --init
./scripts/download_bundles.sh 9.0.1
cd Example && open Example.xcworkspace
```

Set code signing to your own team. The app runs on a device and on the Apple
Silicon Simulator, and exercises every module.

## Maintaining this package

The build is driven by the `Makefile`; `CLAUDE.md` explains the pipeline stage
by stage and `AUTOMATION.md` covers the release automation.

```bash
git submodule update --init          # xcframework-maker
make run                             # build everything into GoogleMLKit/
make verify                          # module lists, Info.plists, product closure
./scripts/verify_runtime.sh          # slices, Info.plists, symbol table
./scripts/verify_local_archive.sh    # run ML Kit on the Simulator, archive for device
./scripts/verify_app_store_upload.sh --upload   # Apple-side validation and delivery
```

`verify_local_archive.sh` is the gate that matters: it runs inference on the
arm64 Simulator, launches the app, archives for device, and checks that every
model bundle reached the app and that nothing was linked dynamically. A missing
model bundle builds and archives perfectly and only fails when inference runs,
so build-time checks alone are not enough.

To pick up a new upstream ML Kit version:

```bash
ruby scripts/check_mlkit_version.rb
./scripts/build_all.sh <version>
```

Or run the **Build MLKit XCFrameworks** workflow from the Actions tab.
