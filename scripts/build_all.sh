#!/bin/bash
set -euo pipefail

# Build script that automates the entire build process
# Usage: ./scripts/build_all.sh <version>

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

# Validate version format (semantic versioning: major.minor.patch with optional pre-release/build metadata)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*)?(\+[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*)?$ ]]; then
  echo "Error: Invalid version format '$VERSION'"
  echo "Expected semantic versioning format: MAJOR.MINOR.PATCH (e.g., 1.2.3, 2.0.0-beta.1, 3.1.4+build.123)"
  exit 1
fi

echo "==================================="
echo "MLKit SwiftPM Build Automation"
echo "Version: $VERSION"
echo "==================================="
echo ""

# Pre-flight checks
echo "Step 0: Pre-flight checks..."
ruby scripts/verify_build.rb || {
  echo "Warning: Some pre-flight checks failed. Continuing anyway..."
}
echo ""

# Step 1: Update Podfile and Info.plist files with new version
echo "Step 1: Updating Podfile and Info.plist files..."
ruby scripts/update_version.rb "$VERSION"
echo ""

# Step 2: Run make to build everything
echo "Step 2: Building XCFrameworks..."
echo "This will take several minutes..."
make run
echo ""

# Step 3: Verify build output
echo "Step 3: Verifying build output..."
ruby scripts/verify_build.rb || {
  echo "Build verification failed!"
  exit 1
}
echo ""

# Step 4: Calculate checksums and update Package.swift
echo "Step 4: Calculating checksums and updating Package.swift..."
ruby scripts/update_checksums.rb "$VERSION"
echo ""

# Step 5: Final verification
echo "Step 5: Final verification..."
ruby scripts/verify_build.rb || {
  echo "Final verification failed!"
  exit 1
}

echo ""
echo "==================================="
echo "✓ Build process completed successfully!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Review the changes:"
echo "   git diff Package.swift Podfile"
echo ""
echo "2. Test the package locally:"
echo "   swift package resolve"
echo ""
echo "3. Commit the changes:"
echo "   git add Podfile Podfile.lock Package.swift Resources/"
echo "   git commit -m \"Update to MLKit $VERSION\""
echo ""
echo "4. Create a GitHub release:"
echo "   gh release create $VERSION GoogleMLKit/*.xcframework.zip \\"
echo "     --title \"Release $VERSION\" \\"
echo "     --notes \"Updated to MLKit $VERSION\""
echo ""
echo "5. Or push and use GitHub Actions to create the release"
echo ""
