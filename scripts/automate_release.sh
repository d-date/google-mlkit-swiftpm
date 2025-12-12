#!/bin/bash
set -euo pipefail

# Automated release workflow
# Usage: ./scripts/automate_release.sh <version>
# Prerequisites: build_all.sh must have completed successfully

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  echo ""
  echo "Prerequisites:"
  echo "  1. Run ./scripts/build_all.sh $VERSION first"
  echo "  2. Test the Example app"
  echo "  3. Run 'swift package resolve' to verify Package.swift"
  exit 1
fi

# Validate version format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Invalid version format '$VERSION'"
  echo "Expected semantic versioning format: X.Y.Z"
  exit 1
fi

echo "==================================="
echo "Automated Release Workflow"
echo "Version: $VERSION"
echo "==================================="
echo ""

# Check prerequisites
echo "Step 1: Checking prerequisites..."

REQUIRED_FILES=(
  "GoogleMLKit/MLImage.xcframework.zip"
  "GoogleMLKit/MLKitBarcodeScanning.xcframework.zip"
  "GoogleMLKit/MLKitCommon.xcframework.zip"
  "GoogleMLKit/MLKitFaceDetection.xcframework.zip"
  "GoogleMLKit/MLKitVision.xcframework.zip"
  "GoogleMLKit/GoogleToolboxForMac.xcframework.zip"
  "GoogleMLKit/GoogleMVFaceDetectorResources.bundle.zip"
)

MISSING_FILES=()
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    MISSING_FILES+=("$file")
  fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
  echo "Error: Missing required files:"
  for file in "${MISSING_FILES[@]}"; do
    echo "  - $file"
  done
  echo ""
  echo "Please run: ./scripts/build_all.sh $VERSION"
  exit 1
fi

echo "✓ All required files present"
echo ""

# Step 2: Create GitHub release
echo "Step 2: Creating GitHub release..."
if ! ./scripts/create_release.sh "$VERSION"; then
  echo "Error: Failed to create GitHub release"
  exit 1
fi
echo ""

# Step 3: Upload artifacts
echo "Step 3: Uploading artifacts to release..."
if ! ./scripts/upload_release.sh "$VERSION"; then
  echo "Error: Failed to upload artifacts"
  exit 1
fi
echo ""

# Step 4: Commit changes
echo "Step 4: Committing changes..."
FILES_TO_ADD=(
  "Podfile"
  "Podfile.lock"
  "Package.swift"
  "README.md"
  "Resources/"
)

# Add optional files if they exist
[ -f "pod_update.log" ] && FILES_TO_ADD+=("pod_update.log")
[ -f "pod_changes_summary.txt" ] && FILES_TO_ADD+=("pod_changes_summary.txt")
[ -f "release_notes_${VERSION}.md" ] && FILES_TO_ADD+=("release_notes_${VERSION}.md")

git add "${FILES_TO_ADD[@]}"
git commit -m "Update to MLKit $VERSION

- Updated XCFrameworks to MLKit $VERSION
- Updated checksums in Package.swift
- Updated README.md with new version

🤖 Generated with Claude Code"

echo "✓ Changes committed"
echo ""

# Step 5: Create and push tag
echo "Step 5: Creating and pushing tag..."
git tag -a "$VERSION" -m "Release MLKit $VERSION

See release notes: https://github.com/d-date/google-mlkit-swiftpm/releases/tag/$VERSION"

echo "✓ Tag created: $VERSION"
echo ""

# Step 6: Push to remote
echo "Step 6: Pushing to remote..."
echo "Pushing commits..."
git push

echo "Pushing tag..."
git push origin "$VERSION"

echo "✓ Pushed to remote"
echo ""

echo "==================================="
echo "✓ Release $VERSION completed successfully!"
echo "==================================="
echo ""
echo "Release URL:"
echo "https://github.com/d-date/google-mlkit-swiftpm/releases/tag/$VERSION"
echo ""
