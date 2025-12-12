# Build Plan for Extended ML Kit Support

## Current State

- Current version in repo: 9.0.0
- **NEW**: Added support for 8 additional ML Kit modules
- Total supported modules: 10 (was 2)

## New Modules Added

### Vision APIs (5 new)
- **Text Recognition** - Recognize text in images (v2)
- **Image Labeling** - Identify objects, locations, activities
- **Object Detection** - Detect and track objects
- **Pose Detection** - Detect body poses
- **Selfie Segmentation** - Segment people from background

### Language APIs (3 new)
- **Language Identification** - Identify language of text
- **Translation** - Translate text between languages  
- **Smart Reply** - Generate contextual reply suggestions

## Build Requirements

Since the package structure has been updated to support new modules, a rebuild is required to:
1. Generate XCFrameworks for all new modules
2. Update checksums in Package.swift
3. Verify all modules work correctly

## Build Strategy

### Rebuild with New Modules

Since this is an expansion of existing version 9.0.0, build with all new modules:

```bash
# Build 9.0.0 with all 10 modules
./scripts/build_all.sh 9.0.0

# This will:
# 1. Install all 10 ML Kit modules via CocoaPods
# 2. Build XCFrameworks for each module
# 3. Generate checksums
# 4. Update Package.swift with correct checksums
# 5. Run verification checks

# Review changes
git diff Package.swift Podfile.lock

# After successful build and testing:
git add -A
git commit -m "Rebuild MLKit 9.0.0 with 8 additional modules

- Add TextRecognition, ImageLabeling, ObjectDetection
- Add PoseDetection, SelfieSegmentation  
- Add LanguageID, Translate, SmartReply
- Total 10 modules now supported (was 2)"
```

## Creating GitHub Releases

After successful build and testing, update the existing 9.0.0 release with new XCFrameworks:

### Option A: Using upload script

```bash
# Upload all XCFrameworks to existing 9.0.0 release
./scripts/upload_release.sh 9.0.0

# This will replace the old XCFrameworks with new ones that include all modules
```

### Option B: Manual upload via GitHub CLI

```bash
# Delete old assets from release (optional)
gh release delete-asset 9.0.0 MLKitBarcodeScanning.xcframework.zip --yes
gh release delete-asset 9.0.0 MLKitFaceDetection.xcframework.zip --yes
# ... repeat for all old assets

# Upload all new XCFrameworks
gh release upload 9.0.0 GoogleMLKit/*.xcframework.zip
```

### Update Release Notes

Edit the 9.0.0 release to document the new modules:

```markdown
# MLKit 9.0.0 - Extended Module Support

This release expands Swift Package Manager support from 2 to 10 ML Kit modules.

## New Modules Added

### Vision APIs
✨ Text Recognition (v2)
✨ Image Labeling
✨ Object Detection & Tracking
✨ Pose Detection
✨ Selfie Segmentation

### Language APIs
✨ Language Identification
✨ Translation
✨ Smart Reply

### Existing Modules
✅ Barcode Scanning
✅ Face Detection

## Installation

See README.md for detailed installation instructions.

## Breaking Changes

None - existing integrations continue to work without modification.
```

## Pre-Build Checklist

Before starting the build process:

- [ ] Verify xcframework-maker is built: `make bootstrap-builder`
- [ ] Check Ruby and dependencies are installed: `bundle install`
- [ ] Verify you have enough disk space (each build ~50-100MB)
- [ ] Check Xcode command line tools are installed: `xcode-select -p`
- [ ] Ensure you're on main branch with clean working directory
- [ ] Run pre-flight check: `ruby scripts/verify_build.rb`

## Build Time Estimates

Each version build takes approximately:

- Pod installation: ~2-5 minutes
- Framework build: ~10-15 minutes
- XCFramework creation: ~2-3 minutes
- Archive and checksum: ~1-2 minutes

**Total per version: ~15-25 minutes**

For 3 versions: **45-75 minutes total**

## Post-Build Verification

After building all versions:

### Static Verification

```bash
# Check git history
git log --oneline -n 3

# Check tags
git tag -l | tail -4

# Verify Package.swift
swift package dump-package

# Check XCFramework sizes
ls -lh GoogleMLKit/*.xcframework.zip

# Run runtime verification
./scripts/verify_runtime.sh 9.0.0
```

### Manual Testing (CRITICAL)

**You MUST test on a physical device before releasing!**

```bash
# Open Example project
cd Example
open Example.xcworkspace
```

**Test Checklist:**

### Basic Tests (Required)
1. [ ] Build for physical iOS device (not simulator)
2. [ ] App launches without crash
3. [ ] Check Xcode console for any errors during startup

### Existing Modules (Must Pass)
4. [ ] Navigate to Barcode Scanner screen
5. [ ] Scan a QR code or barcode
6. [ ] Verify barcode is detected correctly
7. [ ] Navigate to Face Detection screen
8. [ ] Test face detection feature

### New Modules (Verify No Crashes)
9. [ ] Import and initialize TextRecognition - no crash
10. [ ] Import and initialize ImageLabeling - no crash
11. [ ] Import and initialize ObjectDetection - no crash
12. [ ] Import and initialize PoseDetection - no crash
13. [ ] Import and initialize SelfieSegmentation - no crash
14. [ ] Import and initialize LanguageID - no crash
15. [ ] Import and initialize Translate - no crash
16. [ ] Import and initialize SmartReply - no crash

### Console Checks
17. [ ] No "unrecognized selector" errors
18. [ ] No "bundle doesn't contain" errors
19. [ ] No unexpected warnings

**Common Runtime Issues:**

- ❌ App crashes on launch → Missing Info.plist or symbol conflict
- ❌ Crash when using MLKit → Missing `-ObjC` or `-all_load` linker flags
- ❌ "Class X implemented in both..." → Symbol conflict with Firebase
- ❌ Features don't work → Missing resources or incorrect linkage

**If all tests pass:**

```bash
cd ..
git add Podfile Podfile.lock Package.swift Resources/
git commit -m "Update to MLKit 9.0.0 - tested on device"
git tag -a 9.0.0 -m "Release 9.0.0"
```

**See [TESTING.md](TESTING.md) for detailed testing instructions.**

## Troubleshooting

### Build Fails

If a build fails:

1. Check the error message carefully
2. Verify the MLKit version exists: `pod spec cat GoogleMLKit`
3. Clean and retry:
   ```bash
   rm -rf Pods
   rm -rf GoogleMLKit
   ./scripts/build_all.sh <version>
   ```

### CocoaPods Issues

If CocoaPods fails:

```bash
pod repo update
bundle exec pod install
```

### Xcode Issues

If Xcode build fails:

- Check Xcode version: `xcodebuild -version`
- Verify command line tools: `xcode-select --install`
- Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

## Notes

- The build process modifies `Podfile`, `Podfile.lock`, `Package.swift`, and files in `Resources/`
- Each build creates new XCFramework zip files in `GoogleMLKit/` directory
- The zip files from the last build will be used for the GitHub release
- Make sure to upload the correct XCFramework zips for each release
