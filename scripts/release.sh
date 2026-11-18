#!/bin/bash
#
# Builds a release with swiftpods and publishes it as a GitHub Release.
#
#   1. `swiftpods package --version <version>` builds every xcframework and
#      resource bundle zip into build/distribution/ and regenerates
#      Package.swift. --skip-package skips this step (CI packages, commits and
#      tags first, then calls this script for the upload).
#   2. Every *.xcframework.zip that Package.swift references must exist in
#      build/distribution/, point at this version and match its checksum, and
#      the tag <version> on origin must carry this Package.swift -- otherwise
#      consumers would resolve a manifest whose checksums match no asset.
#   3. Creates the GitHub Release <version> (or reuses an existing one) and
#      uploads those xcframework zips plus every *.bundle.zip in
#      build/distribution/.
#
# Locally: run `scripts/release.sh <version>`; when it stops because the tag
# is missing, commit Podfile.swift, Podfile.lock, Package.swift and
# Sources/Common/export.swift, tag <version>, push both, then run
# `scripts/release.sh --skip-package <version>`.
#
# Environment: SWIFTPODS (swiftpods binary, default `swiftpods`); gh needs to
# be authenticated (GH_TOKEN in CI).
#
# Usage: scripts/release.sh [--skip-package] <version>

set -euo pipefail

cd "$(dirname "$0")/.."

usage() {
  echo "usage: $0 [--skip-package] <version>" >&2
  exit 1
}

SKIP_PACKAGE=false
if [ "${1:-}" = "--skip-package" ]; then
  SKIP_PACKAGE=true
  shift
fi
[ $# -eq 1 ] || usage
VERSION="$1"

# major.minor follow ML Kit, the patch number counts wrapper releases.
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]]; then
  echo "error: invalid version '$VERSION' (expected X.Y.Z[-PRERELEASE])" >&2
  exit 1
fi

DIST="build/distribution"
SWIFTPODS="${SWIFTPODS:-swiftpods}"

if ! command -v gh > /dev/null; then
  echo "error: GitHub CLI (gh) not found -- https://cli.github.com/" >&2
  exit 1
fi

if [ "$SKIP_PACKAGE" = false ]; then
  echo "==> swiftpods package --version $VERSION"
  "$SWIFTPODS" package --version "$VERSION"
fi

echo "==> Checking the assets Package.swift references"
# Each binary target is generated as `url: "..."` followed by `checksum: "..."`.
FILES=()
problems=""
url=""
while IFS= read -r line; do
  case "$line" in
    *'url: "'*)
      url="${line#*url: \"}"
      url="${url%%\"*}"
      ;;
    *'checksum: "'*)
      checksum="${line#*checksum: \"}"
      checksum="${checksum%%\"*}"
      name="${url##*/}"
      if [[ "$url" != */releases/download/"$VERSION"/* ]]; then
        problems="$problems\n  $name points at another release: $url"
      elif [ ! -f "$DIST/$name" ]; then
        problems="$problems\n  $DIST/$name is missing"
      elif [ "$(shasum -a 256 "$DIST/$name" | cut -d' ' -f1)" != "$checksum" ]; then
        problems="$problems\n  $DIST/$name does not match its checksum in Package.swift"
      else
        FILES+=("$DIST/$name")
      fi
      url=""
      ;;
  esac
done < <(grep -v '^[[:space:]]*//' Package.swift)

if [ -n "$problems" ]; then
  printf "error: Package.swift and %s/ disagree:%b\n" "$DIST" "$problems" >&2
  exit 1
fi
if [ "${#FILES[@]}" -eq 0 ]; then
  echo "error: Package.swift references no xcframework zip" >&2
  exit 1
fi
XCFRAMEWORK_COUNT=${#FILES[@]}

for bundle in "$DIST"/*.bundle.zip; do
  [ -f "$bundle" ] && FILES+=("$bundle")
done
BUNDLE_COUNT=$((${#FILES[@]} - XCFRAMEWORK_COUNT))

echo "==> Checking that tag $VERSION on origin carries this Package.swift"
if ! git ls-remote --exit-code --tags origin "refs/tags/$VERSION" > /dev/null; then
  cat >&2 << EOF
error: tag $VERSION does not exist on origin. Commit Podfile.swift, Podfile.lock,
Package.swift and Sources/Common/export.swift, tag $VERSION, push the branch and
the tag, then run: $0 --skip-package $VERSION
EOF
  exit 1
fi
git fetch --quiet --no-tags origin "refs/tags/$VERSION"
if ! git diff --quiet FETCH_HEAD -- Package.swift; then
  echo "error: Package.swift differs from the one tagged $VERSION on origin" >&2
  exit 1
fi

if gh release view "$VERSION" > /dev/null 2>&1; then
  echo "==> Release $VERSION exists; replacing its assets"
else
  echo "==> Creating release $VERSION"
  PRERELEASE=()
  [[ "$VERSION" == *-* ]] && PRERELEASE=(--prerelease)
  gh release create "$VERSION" --verify-tag --title "$VERSION" --generate-notes ${PRERELEASE[@]+"${PRERELEASE[@]}"}
fi

echo "==> Uploading $XCFRAMEWORK_COUNT xcframeworks and $BUNDLE_COUNT resource bundles"
gh release upload "$VERSION" "${FILES[@]}" --clobber

echo "Released $VERSION: $(gh release view "$VERSION" --json url --jq .url)"
