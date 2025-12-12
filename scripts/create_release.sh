#!/bin/bash
set -euo pipefail

# Create GitHub release with release notes
# Usage: ./scripts/create_release.sh <version>

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
echo "Create GitHub Release"
echo "Version: $VERSION"
echo "==================================="
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
  if [ -x "/opt/homebrew/bin/gh" ]; then
    GH_CMD="/opt/homebrew/bin/gh"
  else
    echo "Error: GitHub CLI (gh) not found"
    echo "Please install it: https://cli.github.com/"
    exit 1
  fi
else
  GH_CMD="gh"
fi

# Check if release already exists
echo "Checking if release $VERSION already exists..."
if $GH_CMD release view "$VERSION" &> /dev/null; then
  echo "Error: Release $VERSION already exists"
  echo "To update an existing release, use: gh release edit $VERSION"
  exit 1
fi

# Generate release notes
NOTES_FILE="release_notes_${VERSION}.md"
if [ -f "pod_changes_summary.txt" ]; then
  echo "Generating release notes from pod changes..."
  ruby scripts/generate_release_notes.rb "$VERSION" pod_changes_summary.txt
else
  echo "Generating release notes without pod changes..."
  ruby scripts/generate_release_notes.rb "$VERSION"
fi

if [ ! -f "$NOTES_FILE" ]; then
  echo "Error: Failed to generate release notes"
  exit 1
fi

echo ""
echo "Release notes preview:"
echo "---"
head -30 "$NOTES_FILE"
echo "..."
echo "---"
echo ""

# Create release
echo "Creating GitHub release $VERSION..."
$GH_CMD release create "$VERSION" \
  --title "MLKit $VERSION" \
  --notes-file "$NOTES_FILE"

echo ""
echo "==================================="
echo "✓ Successfully created release $VERSION"
echo "==================================="
echo ""
echo "Next step:"
echo "  ./scripts/upload_release.sh $VERSION"
