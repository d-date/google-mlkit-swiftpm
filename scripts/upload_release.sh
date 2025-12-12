#!/bin/bash
set -euo pipefail

# Upload XCFrameworks to GitHub Release
# Usage: ./scripts/upload_release.sh <version>

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

# Validate version format (semantic versioning: X.Y.Z)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Invalid version format '$VERSION'"
  echo "Expected semantic versioning format: X.Y.Z (e.g., 1.2.3, 2.0.0)"
  exit 1
fi

echo "==================================="
echo "Upload Release Artifacts"
echo "Version: $VERSION"
echo "==================================="
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
  if [ -x "/usr/local/bin/gh" ]; then
    GH_CMD="/usr/local/bin/gh"
  else
    echo "Error: GitHub CLI (gh) not found"
    echo "Please install it: https://cli.github.com/"
    exit 1
  fi
else
  GH_CMD="gh"
fi

# Check if release exists
echo "Checking if release $VERSION exists..."
if ! $GH_CMD release view "$VERSION" &> /dev/null; then
  echo "Error: Release $VERSION does not exist"
  echo "Please create the release first with: gh release create $VERSION"
  exit 1
fi

# List of XCFramework files to upload
FRAMEWORKS=(
  "GoogleToolboxForMac"
  "MLImage"
  "MLKitBarcodeScanning"
  "MLKitCommon"
  "MLKitFaceDetection"
  "MLKitVision"
)

# Resource bundle to upload
BUNDLE_NAME="GoogleMVFaceDetectorResources.bundle"

# Delete old assets if they exist
echo "Removing old assets from release..."
for framework in "${FRAMEWORKS[@]}"; do
  ASSET_NAME="${framework}.xcframework.zip"
  if $GH_CMD release view "$VERSION" --json assets --jq ".assets[].name" | grep -q "^${ASSET_NAME}$"; then
    echo "  Deleting old asset: $ASSET_NAME"
    $GH_CMD release delete-asset "$VERSION" "$ASSET_NAME" --yes || true
  fi
done

# Delete old bundle if it exists
BUNDLE_ZIP="${BUNDLE_NAME}.zip"
if $GH_CMD release view "$VERSION" --json assets --jq ".assets[].name" | grep -q "^${BUNDLE_ZIP}$"; then
  echo "  Deleting old asset: $BUNDLE_ZIP"
  $GH_CMD release delete-asset "$VERSION" "$BUNDLE_ZIP" --yes || true
fi
echo ""

# Upload new assets
echo "Uploading new XCFramework assets and bundle..."
UPLOAD_FILES=()
for framework in "${FRAMEWORKS[@]}"; do
  ASSET_PATH="GoogleMLKit/${framework}.xcframework.zip"
  if [ ! -f "$ASSET_PATH" ]; then
    echo "Error: File not found: $ASSET_PATH"
    exit 1
  fi
  UPLOAD_FILES+=("$ASSET_PATH")
  echo "  Prepared: $ASSET_PATH"
done

# Add bundle
BUNDLE_PATH="GoogleMLKit/${BUNDLE_ZIP}"
if [ ! -f "$BUNDLE_PATH" ]; then
  echo "Error: File not found: $BUNDLE_PATH"
  exit 1
fi
UPLOAD_FILES+=("$BUNDLE_PATH")
echo "  Prepared: $BUNDLE_PATH"

echo ""
echo "Uploading ${#UPLOAD_FILES[@]} files to release $VERSION..."
$GH_CMD release upload "$VERSION" "${UPLOAD_FILES[@]}" --clobber

echo ""
echo "==================================="
echo "✓ Successfully uploaded all artifacts to release $VERSION"
echo "==================================="
