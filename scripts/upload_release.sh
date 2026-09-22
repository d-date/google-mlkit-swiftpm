#!/bin/bash
set -euo pipefail

# Uploads every build artifact to an existing GitHub Release.
#
# Usage: ./scripts/upload_release.sh <version>
#
# The asset list is derived from GoogleMLKit/, not enumerated here: this script
# used to name six of the thirty XCFrameworks and one of the eighteen resource
# bundles, so most of a release had to be attached by hand. Every
# `.binaryTarget` in Package.swift must have a matching zip or the upload is
# refused -- a release missing one asset fails for consumers at resolve time.

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

# Accept an optional SemVer pre-release suffix (e.g. "9.0.0-1") so wrapper
# repackages can ship with a tag distinct from the upstream ML Kit version.
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]]; then
  echo "Error: invalid version format '$VERSION' (expected X.Y.Z[-PRERELEASE])" >&2
  exit 1
fi

if ! command -v gh > /dev/null; then
  echo "Error: GitHub CLI (gh) not found -- https://cli.github.com/" >&2
  exit 1
fi

if ! gh release view "$VERSION" > /dev/null 2>&1; then
  echo "Error: release $VERSION does not exist -- create it with 'gh release create $VERSION'" >&2
  exit 1
fi

if [ ! -d GoogleMLKit ]; then
  echo "Error: GoogleMLKit/ not found -- run 'make run' first" >&2
  exit 1
fi

# Every binary target needs its zip. Comment lines are skipped so the check
# reflects what the package actually declares.
missing=""
while read -r name; do
  [ -f "GoogleMLKit/$name.xcframework.zip" ] || missing="$missing $name"
done < <(grep -v '^\s*//' Package.swift | grep -A1 '\.binaryTarget(' | sed -n 's/.*name: "\([^"]*\)".*/\1/p')

if [ -n "$missing" ]; then
  echo "Error: Package.swift declares binary targets with no zip in GoogleMLKit/:$missing" >&2
  exit 1
fi

FILES=()
while IFS= read -r file; do
  FILES+=("$file")
done < <(ls GoogleMLKit/*.xcframework.zip GoogleMLKit/*.bundle.zip 2> /dev/null)

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "Error: no .xcframework.zip or .bundle.zip in GoogleMLKit/" >&2
  exit 1
fi

echo "Uploading ${#FILES[@]} assets to release $VERSION"
echo "  $(ls GoogleMLKit/*.xcframework.zip | wc -l | tr -d ' ') XCFrameworks, $(ls GoogleMLKit/*.bundle.zip | wc -l | tr -d ' ') resource bundles, $(du -ch GoogleMLKit/*.zip | tail -1 | cut -f1) total"

gh release upload "$VERSION" "${FILES[@]}" --clobber

echo
echo "Uploaded $(gh release view "$VERSION" --json assets --jq '.assets | length') assets to $VERSION"
