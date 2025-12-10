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

These checks run automatically during `build_all.sh`:

```bash
ruby scripts/verify_build.rb
```

**What it checks:**
- All XCFramework zip files exist
- Package.swift syntax is valid
- Info.plist files are present
- xcframework-maker is built

### Level 2: Static Analysis (Manual)

Run after building to check for obvious issues:

```bash
./scripts/verify_runtime.sh <version>
```

**What it checks:**
- XCFramework architectures (arm64, x86_64)
- Info.plist presence in each framework
- Symbol table validity
- Package.swift target definitions

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

#### Simulator Testing (Optional)
1. [ ] Build for iOS Simulator (Intel Mac)
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
# 1. Build new version
./scripts/build_all.sh 7.0.0

# 2. Run static analysis
./scripts/verify_runtime.sh 7.0.0

# 3. Test Example app
cd Example
open Example.xcworkspace
# Build and run on device
# Test all features
# Check console

# 4. If all tests pass, commit
cd ..
git add Podfile Podfile.lock Package.swift Resources/
git commit -m "Update to MLKit 7.0.0"
git tag -a 7.0.0 -m "Release 7.0.0"
```

## Batch Build Testing Strategy

When building multiple versions with `batch_build.sh`:

### Option A: Test After Each Version

Pause after each successful build and test:

```bash
# Build first version
./scripts/build_all.sh 7.0.0

# Test it
./scripts/verify_runtime.sh 7.0.0
cd Example && open Example.xcworkspace
# Manual testing...

# If good, commit and continue
git add ... && git commit ... && git tag ...

# Build next version
./scripts/build_all.sh 8.0.0
# ... repeat testing
```

### Option B: Build All, Then Test All

Build all versions, then test the latest:

```bash
# Build all versions
./scripts/batch_build.sh 7.0.0 8.0.0 9.0.0

# Test the latest version (9.0.0)
./scripts/verify_runtime.sh 9.0.0
cd Example && open Example.xcworkspace
# Manual testing...

# If 9.0.0 works, assume others do too
# (Not recommended for major version jumps)
```

### Option C: Sample Testing

Test first and last versions only:

```bash
# Build all
./scripts/batch_build.sh 7.0.0 8.0.0 9.0.0

# Test first (7.0.0)
./scripts/verify_runtime.sh 7.0.0
# ... manual testing

# Test last (9.0.0)
./scripts/verify_runtime.sh 9.0.0
# ... manual testing
```

## Known Issues and Workarounds

### Issue: "The bundle doesn't contain..."

**Cause:** Missing Info.plist in framework

**Solution:**
1. Check `Resources/*-Info.plist` files exist
2. Verify `prepare-info-plist` Makefile target ran
3. Manually copy Info.plist if needed:
   ```bash
   cp Resources/MLKitCommon-Info.plist \
     GoogleMLKit/MLKitCommon.xcframework/ios-arm64/MLKitCommon.framework/Info.plist
   ```

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

**Cause:** MLKit doesn't include arm64 simulator slice

**Solution:**
- Test on Intel Mac simulator
- Or test on physical device only
- Known limitation documented in README

## Automated Testing (Future Enhancement)

Consider adding:

1. **Unit Tests**
   ```swift
   // Test basic MLKit initialization
   func testMLKitBarcodeScanner() {
     let scanner = BarcodeScanner.barcodeScanner()
     XCTAssertNotNil(scanner)
   }
   ```

2. **Integration Tests**
   - Use sample images
   - Test barcode detection
   - Test face detection

3. **CI/CD Testing**
   - GitHub Actions to build Example app
   - Run basic smoke tests
   - Fail if crashes detected

## Regression Testing

When updating to new MLKit versions, verify:

- [ ] No new runtime errors
- [ ] Same features work as before
- [ ] Performance is similar or better
- [ ] No new symbol conflicts
- [ ] Backwards compatibility maintained

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
