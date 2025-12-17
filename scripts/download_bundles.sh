#!/bin/bash

set -e

VERSION=${1:-9.0.0}
DEST_DIR="Example/Example/Resources/Bundles"

echo "Downloading ML Kit resource bundles for version ${VERSION}..."

# Create destination directory
mkdir -p "${DEST_DIR}"

# Download and extract bundles
BUNDLES=(
  "GoogleMVFaceDetectorResources.bundle"
  "MLKitImageLabelingResources.bundle"
  "MLKitObjectDetectionCommonResources.bundle"
  "MLKitObjectDetectionResources.bundle"
  "PredictOnDevice_resource.bundle"
  "MLKitTranslate_resource.bundle"
  "MLKitXenoResources.bundle"
)

for BUNDLE in "${BUNDLES[@]}"; do
  echo "Downloading ${BUNDLE}..."
  curl -L -o "/tmp/${BUNDLE}.zip" \
    "https://github.com/d-date/google-mlkit-swiftpm/releases/download/${VERSION}/${BUNDLE}.zip"

  echo "Extracting ${BUNDLE}..."
  unzip -q -o "/tmp/${BUNDLE}.zip" -d "${DEST_DIR}"
  rm "/tmp/${BUNDLE}.zip"

  echo "✓ ${BUNDLE} installed"
done

echo ""
echo "All bundles downloaded successfully!"
echo ""
echo "Next steps:"
echo "1. Open Example/Example.xcodeproj in Xcode"
echo "2. Drag the 'Bundles' folder from Example/Example/Resources/ into the Xcode project"
echo "3. Check 'Copy items if needed' and add to the Example target"
echo "4. Build and run"
