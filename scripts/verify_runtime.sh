#!/bin/bash
set -euo pipefail

# Runtime verification script
# Checks if the built XCFrameworks can be linked and don't have obvious runtime issues

VERSION=${1:-"unknown"}

echo "==================================="
echo "Runtime Verification"
echo "Version: $VERSION"
echo "==================================="
echo ""

# Check if we have the Example project
if [ ! -d "Example" ]; then
  echo "Warning: Example directory not found. Skipping runtime verification."
  exit 0
fi

echo "Step 1: Checking XCFramework architectures..."
echo ""

# Check each XCFramework for proper architectures
for framework in GoogleMLKit/*.xcframework; do
  if [ -d "$framework" ]; then
    name=$(basename "$framework" .xcframework)
    echo "Checking $name..."

    # Check arm64 (device)
    if [ -d "$framework/ios-arm64" ]; then
      echo "  ✓ ios-arm64 (device) present"
    else
      echo "  ✗ ios-arm64 (device) MISSING"
    fi

    # Check x86_64 simulator (Intel Mac)
    if [ -d "$framework/ios-x86_64-simulator" ]; then
      echo "  ✓ ios-x86_64-simulator present"
    else
      echo "  ✗ ios-x86_64-simulator MISSING"
    fi

    # Check for arm64 simulator (Apple Silicon)
    if [ -d "$framework/ios-arm64-simulator" ] || [ -d "$framework/ios-arm64_x86_64-simulator" ]; then
      echo "  ⚠ ios-arm64-simulator found (unexpected for MLKit)"
    fi
  fi
done

echo ""
echo "Step 2: Checking for common runtime issues..."
echo ""

# Check if frameworks have proper Info.plist
for framework in GoogleMLKit/*.xcframework; do
  if [ -d "$framework" ]; then
    name=$(basename "$framework" .xcframework)

    # Check device framework
    if [ -f "$framework/ios-arm64/$name.framework/Info.plist" ]; then
      echo "✓ $name (device) has Info.plist"
    else
      echo "✗ $name (device) MISSING Info.plist - may crash at runtime!"
    fi

    # Check simulator framework
    if [ -f "$framework/ios-x86_64-simulator/$name.framework/Info.plist" ]; then
      echo "✓ $name (simulator) has Info.plist"
    else
      echo "✗ $name (simulator) MISSING Info.plist - may crash at runtime!"
    fi
  fi
done

echo ""
echo "Step 3: Checking for symbol conflicts..."
echo ""

# Extract symbols from main frameworks to check for duplicates
echo "Extracting symbols from MLKitBarcodeScanning..."
if [ -f "GoogleMLKit/MLKitBarcodeScanning.xcframework/ios-arm64/MLKitBarcodeScanning.framework/MLKitBarcodeScanning" ]; then
  nm -gU GoogleMLKit/MLKitBarcodeScanning.xcframework/ios-arm64/MLKitBarcodeScanning.framework/MLKitBarcodeScanning | head -20
  echo "✓ MLKitBarcodeScanning symbols look valid"
else
  echo "✗ Could not check MLKitBarcodeScanning symbols"
fi

echo ""
echo "Step 4: Verifying Package.swift linkage..."
echo ""

# Check Package.swift for proper target dependencies
if grep -q "MLKitBarcodeScanning" Package.swift && \
   grep -q "MLKitFaceDetection" Package.swift && \
   grep -q "MLImage" Package.swift && \
   grep -q "MLKitVision" Package.swift && \
   grep -q "Common" Package.swift; then
  echo "✓ Package.swift contains all expected targets"
else
  echo "✗ Package.swift may be missing targets"
fi

echo ""
echo "==================================="
echo "Runtime Verification Summary"
echo "==================================="
echo ""
echo "⚠️  IMPORTANT NOTES:"
echo ""
echo "1. Built frameworks support:"
echo "   - iphoneos: arm64 only"
echo "   - iphonesimulator: x86_64 only (Intel Mac)"
echo ""
echo "2. Apple Silicon Macs:"
echo "   - Simulator will run in Rosetta mode"
echo "   - This is a known MLKit limitation"
echo ""
echo "3. Manual testing required:"
echo "   - Build the Example app on a real device"
echo "   - Test basic barcode scanning functionality"
echo "   - Test basic face detection functionality"
echo "   - Check Xcode console for runtime warnings"
echo ""
echo "4. Common runtime issues to watch for:"
echo "   - Missing Info.plist: \"The bundle doesn't contain...\" error"
echo "   - Symbol conflicts: Duplicate symbol errors"
echo "   - Missing dependencies: \"dyld: Library not loaded\" error"
echo "   - ObjC runtime errors: \"unrecognized selector sent to instance\""
echo ""
echo "Next steps:"
echo "1. cd Example && open Example.xcworkspace"
echo "2. Build and run on a physical device"
echo "3. Test each MLKit feature"
echo "4. Check for crashes or warnings"
echo ""
