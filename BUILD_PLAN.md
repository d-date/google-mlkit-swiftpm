# Build Plan for Missing MLKit Versions

## Current State

- Current version in repo: 5.0.0 (tag: 5.0.0)
- Latest git tag: 6.0.0
- Latest MLKit version: 9.0.0

## Missing Versions

The following versions need to be built and tagged:

- **7.0.0** - Released after 6.0.0
- **8.0.0** - Released after 7.0.0
- **9.0.0** - Latest version (current)

## Build Strategy

### Option 1: Manual Sequential Build (Recommended for First Time)

Build each version manually to ensure quality and catch any issues:

```bash
# Build 7.0.0
./scripts/build_all.sh 7.0.0
git add Podfile Podfile.lock Package.swift Resources/
git commit -m "Update to MLKit 7.0.0"
git tag -a 7.0.0 -m "Release 7.0.0"

# Build 8.0.0
./scripts/build_all.sh 8.0.0
git add Podfile Podfile.lock Package.swift Resources/
git commit -m "Update to MLKit 8.0.0"
git tag -a 8.0.0 -m "Release 8.0.0"

# Build 9.0.0
./scripts/build_all.sh 9.0.0
git add Podfile Podfile.lock Package.swift Resources/
git commit -m "Update to MLKit 9.0.0"
git tag -a 9.0.0 -m "Release 9.0.0"

# Push everything
git push origin main
git push origin --tags
```

### Option 2: Batch Build (Faster but Less Control)

Use the batch build script to build all versions automatically:

```bash
./scripts/batch_build.sh 7.0.0 8.0.0 9.0.0
```

This will:
- Build each version sequentially
- Create git commits automatically
- Create git tags automatically
- Stop and ask if you want to continue on failure

After successful batch build:

```bash
# Push everything
git push origin main
git push origin --tags
```

## Creating GitHub Releases

After pushing tags, create GitHub releases for each version:

### Option A: Using GitHub CLI

```bash
# For each version
gh release create 7.0.0 GoogleMLKit/*.xcframework.zip \
  --title "Release 7.0.0" \
  --notes "Updated to MLKit 7.0.0"

gh release create 8.0.0 GoogleMLKit/*.xcframework.zip \
  --title "Release 8.0.0" \
  --notes "Updated to MLKit 8.0.0"

gh release create 9.0.0 GoogleMLKit/*.xcframework.zip \
  --title "Release 9.0.0" \
  --notes "Updated to MLKit 9.0.0"
```

### Option B: Using GitHub Actions

1. Go to Actions tab
2. Run "Build MLKit XCFrameworks" workflow
3. Enter version number
4. Select "Create GitHub release"
5. Click "Run workflow"

**Note:** You'll need to run this for each version separately.

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

```bash
# Check git history
git log --oneline -n 3

# Check tags
git tag -l | tail -4

# Verify Package.swift
swift package dump-package

# Check XCFramework sizes
ls -lh GoogleMLKit/*.xcframework.zip
```

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
