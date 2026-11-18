# Testing Guide for MLKit SwiftPM

This guide explains how to test MLKit builds to prevent runtime crashes.

## Why Testing is Critical

MLKit frameworks can have runtime issues that don't appear at build time:

1. **Missing Info.plist** - Causes "The bundle doesn't contain..." errors
2. **Symbol Conflicts** - Firebase/MLKit dependency conflicts
3. **Architecture Issues** - Wrong or missing architectures
4. **ObjC Runtime** - Missing selectors or categories

## Testing Levels

### Level 1: Build-Time Verification (Automatic)

`swiftpods package --version <version>` checks these itself:

- every prebuilt framework gets an `Info.plist` and an arm64 simulator slice
- every product is linked on its own into an iOS executable for the simulator
  and the device, with `-ObjC -all_load` (catches a product that omits a
  transitive framework)

Then confirm the generated manifest parses:

```bash
swift package dump-package > /dev/null
```

### Level 2: Runtime Tests on the Simulator (Required)

```bash
./scripts/verify_local_archive.sh
```

It points `Package.swift` at `build/distribution/`, runs the SwiftPM test
target `CameraTests` (`Example/Package/Tests/CameraTests`) on the arm64
Simulator, launches the Example app, archives for device and checks the
archive (no embedded GoogleToolboxForMac/SSZipArchive, nothing linked
dynamically, every model bundle present, model data not dead-stripped).

**`CameraTests` needs the model bundles inside the test bundle.** ML Kit
resolves its models against the main bundle, which for a SwiftPM test target
is the test runner, so text recognition only works when
`LatinOCRResources.bundle` is copied into the built `CameraTests.xctest`;
`verify_local_archive.sh` copies every bundle there. Verified 2026-11-18:
without the bundle, both the 9.0.3 artifacts and the swiftpods-built ones fail
with "Invalid model path."; with it copied into `CameraTests.xctest`, the
swiftpods-built artifacts pass all 5 `CameraTests`.

### Level 3: Example App Testing (Required)

**This is the most important test!** Build and run the Example app:

```bash
cd Example
open Example.xcworkspace
```

**Test checklist:**

#### Device Testing (Required)
1. [ ] Build for physical iOS device
2. [ ] App launches without crash
3. [ ] Navigate to Barcode Scanner
4. [ ] Scan a barcode (QR code)
5. [ ] Check console for warnings
6. [ ] Navigate to Face Detection
7. [ ] Use face detection feature
8. [ ] Check console for warnings
9. [ ] Test Text Recognition (if UI available)
10. [ ] Test Image Labeling (if UI available)
11. [ ] Test Object Detection (if UI available)
12. [ ] Test Pose Detection (if UI available)
13. [ ] Test Selfie Segmentation (if UI available)
14. [ ] Test Language ID (if UI available)
15. [ ] Test Translation (if UI available)
16. [ ] Test Smart Reply (if UI available)

#### Simulator Testing (Optional)
1. [ ] Build for iOS Simulator
2. [ ] App launches without crash
3. [ ] Basic UI navigation works
4. [ ] Note: Camera may not work in simulator

**Common Issues to Watch For:**

❌ **Crash on launch**
- Missing Info.plist
- Symbol conflicts with Firebase
- Wrong architecture

❌ **Crash when using MLKit features**
- Missing ObjC categories (use `-ObjC` linker flag)
- Missing resources (face detection models)
- Incomplete binary linkage (use `-all_load`)

❌ **Runtime warnings**
- "Class X is implemented in both..." (symbol conflict)
- "Could not load bundle..." (missing resources)

## Testing After Each Build

### Recommended Testing Flow

```bash
# 1. Build the XCFrameworks and regenerate Package.swift
swiftpods package --version <version>

# 2. Run ML Kit on the Simulator and archive for device
./scripts/verify_local_archive.sh

# 3. Test Example app
cd Example
open Example.xcworkspace
# Build and run on device
# Test all features
# Check console

# 4. If all tests pass, commit, tag, push and release
cd ..
git add Podfile.swift Podfile.lock Package.swift Sources/Common/export.swift
git commit -m "Release <version>"
git tag <version>
git push origin HEAD <version>
scripts/release.sh --skip-package <version>
```

## Known Issues and Workarounds

### Issue: "The bundle doesn't contain..."

**Cause:** Missing Info.plist in framework

**Solution:** `swiftpods package` adds an `Info.plist` to every prebuilt
framework that lacks one. Check the framework in
`build/distribution/<Name>.xcframework` and report it to swiftpods if the
plist is missing.

### Issue: Duplicate symbol errors

**Cause:** App uses Firebase SDK and MLKit

**Solution:**
- Use Firebase's MLKit via `pod 'Firebase/MLKit'` instead
- Or ensure no Firebase dependencies in main app

### Issue: "unrecognized selector sent to instance"

**Cause:** Missing `-ObjC` linker flag

**Solution:**
1. Open Xcode project
2. Build Settings → Other Linker Flags
3. Add `-ObjC` and `-all_load`

### Issue: Simulator on Apple Silicon crashes

**Cause:** ML Kit doesn't include an arm64 simulator slice

**Solution:** `swiftpods package` synthesises it from the device slice; check
with `lipo -archs` on the simulator slice in `build/distribution/`.

## Reporting Issues

If you find runtime issues:

1. Note the exact error message
2. Note the iOS version and device
3. Note the Xcode version used
4. Check if issue exists in official CocoaPods version
5. Report to: https://github.com/d-date/google-mlkit-swiftpm/issues

Include:
- MLKit version number
- Steps to reproduce
- Crash logs or console output
- Whether it's a regression (worked in previous version)
