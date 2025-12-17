# ML Kit Demo App

A comprehensive SwiftUI demonstration of all 17 ML Kit features for iOS.

## Setup Instructions

### 1. Add SwiftPM Dependencies in Xcode

Open the project:

```bash
cd Example
open Example.xcodeproj
```

In Xcode:

1. Select the project in the Project Navigator
2. Select the "Example" project (not the target)
3. Go to "Package Dependencies" tab
4. Click "+" to add a package
5. Click "Add Local..." button
6. Navigate to and select the `Package` folder (Example/Package/)
7. Click "Add Package"
8. Select "Camera" library and add it to the "Example" target
9. Build the project (⌘B) to download all dependencies

### 2. Add New Files to Xcode Project

The following new files need to be added to the Xcode project:

**Main App:**

- `MLKitDemoApp.swift` (already added, main entry point)

**Views:**

- `Views/MainMenuView.swift`
- `Views/Base/BaseDetectionView.swift`
- `Views/Base/CameraView.swift`

**Vision Views (14):**

- `Views/Vision/FaceDetectionView.swift`
- `Views/Vision/BarcodeScanningView.swift`
- `Views/Vision/TextRecognitionView.swift`
- `Views/Vision/TextRecognitionChineseView.swift`
- `Views/Vision/TextRecognitionDevanagariView.swift`
- `Views/Vision/TextRecognitionJapaneseView.swift`
- `Views/Vision/TextRecognitionKoreanView.swift`
- `Views/Vision/ImageLabelingView.swift`
- `Views/Vision/ImageLabelingCustomView.swift`
- `Views/Vision/ObjectDetectionView.swift`
- `Views/Vision/ObjectDetectionCustomView.swift`
- `Views/Vision/PoseDetectionView.swift`
- `Views/Vision/PoseDetectionAccurateView.swift`
- `Views/Vision/SelfieSegmentationView.swift`

**Language Views (3):**

- `Views/Language/LanguageIDView.swift`
- `Views/Language/TranslationView.swift`
- `Views/Language/SmartReplyView.swift`

**Resources:**

- `Resources/` folder with all 17 files (15 images + bird.tflite)

**Files to Remove from Project (if present):**

- `ContentView.swift` (deleted)
- `ExampleApp.swift` (deleted)
- `VisionExample/` folder (deleted)

### 3. Download ML Kit Resource Bundles

From the project root directory, run:

```bash
./scripts/download_bundles.sh
```

This will download all required `.bundle` files from the GitHub release and place them in `Example/Example/Resources/Bundles/`.

### 4. Add Resources to Xcode Project

In Xcode:

1. Right-click on the `Example` target in the Project Navigator
2. Select "Add Files to 'Example'..."
3. Navigate to `Example/Example/Resources/`
4. Select both the `Bundles` folder and all image files
5. Check "Copy items if needed"
6. Check "Create folder references" (not "Create groups")
7. Ensure "Example" target is checked
8. Click "Add"

Verify in Build Phases → Copy Bundle Resources:

- All 7 `.bundle` folders are present
- bird.tflite is present
- All sample images are present

### 4. Update Info.plist

Add camera and photo library permissions:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to capture images for ML Kit detection</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is required to select images for ML Kit detection</string>
```

### 5. Build and Run

- Select a physical iOS device (iOS 15.5+)
- Build and run (⌘R)
- Test all features

## Features

### Vision (14 features)

✅ Face Detection
✅ Barcode Scanning
✅ Text Recognition (5 language variants)
✅ Image Labeling (Standard + Custom)
✅ Object Detection (Standard + Custom)
✅ Pose Detection (2 accuracy modes)
✅ Selfie Segmentation

### Language (3 features)

✅ Language Identification
✅ Translation
✅ Smart Reply

## Architecture

- **SwiftUI** with modern iOS 26.0+ patterns
- **NavigationStack** for navigation
- **async/await** for concurrency
- **BaseDetectionView** reusable component for vision features
- **AGENTS.md** compliant code style

## Troubleshooting

### "Image not found"

- Verify Resources folder is added to project
- Check images are in "Copy Bundle Resources" build phase
- Image names should NOT include file extensions when referenced

### "bird.tflite not found"

- Ensure bird.tflite is in "Copy Bundle Resources"
- Check Bundle.main.path(forResource: "bird", ofType: "tflite") returns valid path

### Translation "Model download failed"

- First use requires WiFi for model download
- Check network connection
- Allow background downloads in app

### Camera not working

- Check Info.plist has NSCameraUsageDescription
- Grant camera permission in Settings
- Test on physical device (simulator camera limited)

## Documentation

See `IMPLEMENTATION.md` for detailed architecture and implementation notes.
