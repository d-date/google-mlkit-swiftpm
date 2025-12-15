# ML Kit Demo App Implementation

## Overview
A comprehensive SwiftUI-based demonstration app showcasing all 17 ML Kit features, built following AGENTS.md guidelines for modern iOS development.

## Architecture

### Tech Stack
- **iOS Version**: 26.0+
- **Swift Version**: 6.2+
- **UI Framework**: SwiftUI with modern patterns
- **Concurrency**: async/await throughout
- **Navigation**: NavigationStack (not deprecated NavigationView)

### Project Structure
```
Example/Example/
├── MLKitDemoApp.swift              # App entry point (@main)
├── Resources/                       # Sample images and models (17 files)
│   ├── *.jpg, *.png                # Test images for vision features
│   └── bird.tflite                 # Custom TensorFlow Lite model
├── Views/
│   ├── MainMenuView.swift          # Main navigation menu
│   ├── Base/
│   │   ├── BaseDetectionView.swift # Reusable vision feature template
│   │   └── CameraView.swift        # Camera capture wrapper
│   ├── Vision/                     # 14 vision feature views
│   │   ├── FaceDetectionView.swift
│   │   ├── BarcodeScanningView.swift
│   │   ├── TextRecognitionView.swift
│   │   ├── TextRecognitionChineseView.swift
│   │   ├── TextRecognitionDevanagariView.swift
│   │   ├── TextRecognitionJapaneseView.swift
│   │   ├── TextRecognitionKoreanView.swift
│   │   ├── ImageLabelingView.swift
│   │   ├── ImageLabelingCustomView.swift
│   │   ├── ObjectDetectionView.swift
│   │   ├── ObjectDetectionCustomView.swift
│   │   ├── PoseDetectionView.swift
│   │   ├── PoseDetectionAccurateView.swift
│   │   └── SelfieSegmentationView.swift
│   └── Language/                   # 3 language feature views
│       ├── LanguageIDView.swift
│       ├── TranslationView.swift
│       └── SmartReplyView.swift
```

## Features Implemented (17/17)

### Vision Features (14)

1. **Face Detection** - Detects faces with landmarks, contours, and classifications
   - Sample: grace_hopper.jpg
   - Shows: smiling probability, eye open probability, head angle

2. **Barcode Scanning** - Scans 13 barcode formats
   - Samples: barcode_128.png, qr_code.jpg
   - Formats: Code 128/39/93, QR, EAN, UPC, PDF417, Aztec, etc.

3-7. **Text Recognition** (5 language variants)
   - Latin: image_has_text.jpg
   - Chinese: chinese.png, chinese_sparse.png
   - Devanagari: devanagari.png, devanagari_sparse.png
   - Japanese: japanese.png, japanese_sparse.png
   - Korean: korean.png, korean_sparse.png

8. **Image Labeling** - Standard on-device labeling
   - Samples: bird.jpg, beach.jpg, liberty.jpg
   - Shows labels with confidence scores

9. **Image Labeling (Custom)** - Custom TFLite model labeling
   - Sample: bird.jpg
   - Model: bird.tflite

10. **Object Detection** - 4 modes in one view
    - Modes: Single/Multiple objects, With/Without classification
    - Samples: bird.jpg, beach.jpg, liberty.jpg
    - Shows: bounding boxes, labels, tracking IDs

11. **Object Detection (Custom)** - Custom model with 4 modes
    - Same modes as standard object detection
    - Uses bird.tflite model

12-13. **Pose Detection** (2 accuracy modes)
    - Standard and Accurate modes
    - Samples: grace_hopper.jpg, beach.jpg
    - Shows: 33 body landmarks with positions

14. **Selfie Segmentation** - Foreground/background separation
    - Sample: grace_hopper.jpg
    - Generates and visualizes segmentation mask

### Language Features (3)

15. **Language Identification**
    - Text input with sample texts in 7 languages
    - Shows detected language code and confidence

16. **Translation**
    - 6 languages: English, Japanese, Chinese, Korean, Spanish, French
    - Source/target language pickers
    - Automatic model download

17. **Smart Reply**
    - Conversation interface
    - Generates contextual reply suggestions
    - Add messages and select suggested replies

## Key Design Patterns

### BaseDetectionView Pattern
Generic reusable view for vision features:
```swift
BaseDetectionView(
  title: String,
  sampleImages: [String],
  detectionHandler: (UIImage) async throws -> Void,
  resultView: () -> Content
)
```

Features:
- Photo library picker
- Camera capture
- Sample image navigation (prev/next)
- Detection button with loading state
- Error handling with user-friendly messages

### AGENTS.md Compliance

✅ **2-space indentation** (not tabs)
✅ **NavigationStack** instead of deprecated NavigationView
✅ **foregroundStyle()** instead of foregroundColor()
✅ **clipShape(.rect(cornerRadius:))** instead of cornerRadius()
✅ **Modern number formatting**: `.percent`, `.number.precision()` instead of String(format:)
✅ **onChange(of:) 2-parameter version**: `onChange(of:) { old, new in }`
✅ **ForEach** with enumerated: `enumerated().map { $0 }` not `Array(enumerated())`
✅ **async/await** throughout, no GCD
✅ **#Preview** with NavigationStack

## Sample Images

All 17 files copied to `Example/Example/Resources/`:

| File | Purpose |
|------|---------|
| grace_hopper.jpg | Face detection, pose detection |
| barcode_128.png | Barcode scanning (Code 128) |
| qr_code.jpg | QR code scanning |
| image_has_text.jpg | Text recognition (Latin) |
| chinese.png, chinese_sparse.png | Text recognition (Chinese) |
| devanagari.png, devanagari_sparse.png | Text recognition (Devanagari) |
| japanese.png, japanese_sparse.png | Text recognition (Japanese) |
| korean.png, korean_sparse.png | Text recognition (Korean) |
| bird.jpg, beach.jpg, liberty.jpg | Image labeling, object detection |
| bird.tflite | Custom TFLite model (3.6 MB) |

**Total size**: ~10 MB

## Testing Checklist

### Before Device Testing
- [ ] Ensure Xcode project includes Resources folder in target
- [ ] Verify bird.tflite is in bundle resources
- [ ] Check camera permissions in Info.plist
- [ ] Confirm all ML Kit dependencies are linked

### On Physical Device
Vision Features:
- [ ] Face Detection with camera and sample
- [ ] Barcode Scanning with both barcodes
- [ ] All 5 Text Recognition variants
- [ ] Image Labeling with all samples
- [ ] Image Labeling Custom (bird model)
- [ ] Object Detection all 4 modes
- [ ] Object Detection Custom all 4 modes
- [ ] Pose Detection both accuracy modes
- [ ] Selfie Segmentation with camera

Language Features:
- [ ] Language ID with various inputs
- [ ] Translation with model download
- [ ] Smart Reply conversation flow

User Interactions:
- [ ] Photo library picker
- [ ] Camera capture
- [ ] Sample image navigation
- [ ] All navigation links
- [ ] Error handling (no permissions, etc.)

## Known Considerations

1. **Custom Model**: bird.tflite must be in app bundle
2. **Translation**: First use requires model download (WiFi recommended)
3. **Camera**: Requires camera permission in Info.plist
4. **Photo Library**: Requires photo library permission
5. **Image Names**: No file extensions in sample image references (UIImage(named:) handles this)

## Development Notes

### Removed Legacy Code
- ❌ ContentView.swift (old monolithic view)
- ❌ ExampleApp.swift (old app entry)
- ❌ VisionExample/ directory (UIKit-based implementation)

### App Entry Point
`MLKitDemoApp.swift` is the single source of truth with `@main` attribute.

### Code Style
All code follows Swift 6.2 conventions:
- Strict concurrency
- MainActor where needed
- No force unwraps
- Proper error handling
- Modern SwiftUI patterns
