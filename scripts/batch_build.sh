#!/bin/bash
set -euo pipefail

# Batch build script for multiple MLKit versions
# Usage: ./scripts/batch_build.sh [--non-interactive] <version1> <version2> ...

# Parse flags
NON_INTERACTIVE=false
VERSIONS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --non-interactive)
      NON_INTERACTIVE=true
      shift
      ;;
    *)
      VERSIONS+=("$1")
      shift
      ;;
  esac
done

if [ ${#VERSIONS[@]} -eq 0 ]; then
  echo "Usage: $0 [--non-interactive] <version1> [version2] [version3] ..."
  echo ""
  echo "Options:"
  echo "  --non-interactive  Skip interactive prompts (useful for CI/CD)"
  echo ""
  echo "Example:"
  echo "  $0 7.0.0 8.0.0 9.0.0"
  echo "  $0 --non-interactive 7.0.0 8.0.0 9.0.0"
  exit 1
fi

FAILED_VERSIONS=()
SUCCESS_VERSIONS=()

echo "========================================"
echo "MLKit SwiftPM Batch Build"
echo "Versions to build: ${VERSIONS[*]}"
echo "========================================"
echo ""

for VERSION in "${VERSIONS[@]}"; do
  echo ""
  echo "========================================"
  echo "Building version: $VERSION"
  echo "========================================"
  echo ""

  if ./scripts/build_all.sh "$VERSION"; then
    SUCCESS_VERSIONS+=("$VERSION")
    echo ""
    echo "✓ Successfully built version $VERSION"
    echo ""

    # Create a git commit for this version
    echo "Creating git commit for version $VERSION..."
    git add Podfile Podfile.lock Package.swift Resources/
    git commit -m "Update to MLKit $VERSION

- Updated Podfile to version $VERSION
- Rebuilt XCFrameworks
- Updated checksums in Package.swift

🤖 Generated with batch build automation" || {
      echo "Warning: Could not create commit (may already exist)"
    }

    # Create a git tag
    echo "Creating git tag $VERSION..."
    git tag -a "$VERSION" -m "Release $VERSION" || {
      echo "Warning: Tag $VERSION already exists"
    }

  else
    FAILED_VERSIONS+=("$VERSION")
    echo ""
    echo "✗ Failed to build version $VERSION"
    echo ""

    # Ask user if they want to continue (only in interactive mode)
    if [ "$NON_INTERACTIVE" = false ] && [ -t 0 ]; then
      read -p "Continue with next version? (y/n) " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        break
      fi
    else
      echo "Continuing with next version automatically..."
    fi
  fi
done

echo ""
echo "========================================"
echo "Batch Build Summary"
echo "========================================"
echo ""
echo "Total versions: ${#VERSIONS[@]}"
echo "Successful: ${#SUCCESS_VERSIONS[@]}"
echo "Failed: ${#FAILED_VERSIONS[@]}"
echo ""

if [ ${#SUCCESS_VERSIONS[@]} -gt 0 ]; then
  echo "✓ Successfully built versions:"
  for VERSION in "${SUCCESS_VERSIONS[@]}"; do
    echo "  - $VERSION"
  done
  echo ""
fi

if [ ${#FAILED_VERSIONS[@]} -gt 0 ]; then
  echo "✗ Failed versions:"
  for VERSION in "${FAILED_VERSIONS[@]}"; do
    echo "  - $VERSION"
  done
  echo ""
fi

echo "Next steps:"
echo "1. Review the git log: git log --oneline -n ${#SUCCESS_VERSIONS[@]}"
echo "2. Review the tags: git tag -l"
echo "3. Push commits: git push origin main"
echo "4. Push tags: git push origin --tags"
echo ""
echo "Or create GitHub releases for each version:"
for VERSION in "${SUCCESS_VERSIONS[@]}"; do
  echo "  gh release create $VERSION GoogleMLKit/*.xcframework.zip \\"
  echo "    --title \"Release $VERSION\" \\"
  echo "    --notes \"Updated to MLKit $VERSION\""
done
