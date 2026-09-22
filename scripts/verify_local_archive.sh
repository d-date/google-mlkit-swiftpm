#!/bin/bash
#
# Builds and archives the Example app against the XCFrameworks in GoogleMLKit/,
# so a release can be validated before it is published. Checks the three things
# that repeatedly broke consumers:
#
#   * ML Kit actually runs: the tests recognise text, scan a barcode and
#     identify a language on the arm64 Simulator. This is the only check that
#     catches a missing model bundle (issue #106/#109: text recognition threw
#     "Invalid model path." because LatinOCRResources.bundle was never shipped)
#     and the only one that proves the synthesised arm64 simulator slices
#     execute rather than merely link (issue #112)
#   * the app links and archives for a real device (issue #110: a product that
#     omits a transitive framework fails at link time)
#   * no ML Kit framework is embedded in the archive (issue #102: an embedded
#     dynamic copy of a "commonly used third-party SDK" is rejected with
#     ITMS-91065) and MLKitTextRecognitionCommon keeps its OCR model data
#     (issue #106: relinking it as a dylib dead-stripped ~60MB down to ~33KB)
#
# Package.swift is repointed at the local XCFrameworks for the duration and
# restored on exit.
#
# Usage: ./scripts/verify_local_archive.sh

set -euo pipefail

WORKSPACE="Example/Example.xcworkspace"
SCHEME="Example"
DERIVED_DATA="${TMPDIR:-/tmp}/mlkit-verify-derived"
SIMULATOR="${MLKIT_VERIFY_SIMULATOR:-platform=iOS Simulator,name=iPhone 17 Pro}"
ARCHIVE_PATH="${TMPDIR:-/tmp}/mlkit-verify.xcarchive"

if [ ! -d GoogleMLKit ]; then
  echo "error: GoogleMLKit/ not found -- run 'make run' first" >&2
  exit 1
fi

# Restore from a copy rather than with `git checkout`: Package.swift normally
# has uncommitted changes while a fix is being verified.
PACKAGE_BACKUP="${TMPDIR:-/tmp}/Package.swift.orig"
cp Package.swift "$PACKAGE_BACKUP"

restore() {
  cp "$PACKAGE_BACKUP" Package.swift
  rm -f "$PACKAGE_BACKUP"
  echo "Restored Package.swift"
}
trap restore EXIT

echo "==> Pointing Package.swift at local XCFrameworks"
ruby scripts/use_local_binaries.rb

echo "==> Refreshing the resource bundles the Example app carries"
# SwiftPM cannot carry a bundle inside a binary target, so the Example app
# keeps its own copies checked in. Sync them with what was just built -- a diff
# here means the bundles on the release need updating too.
mkdir -p Example/Example/Resources/Bundles
cp -rf GoogleMLKit/*.bundle Example/Example/Resources/Bundles/

echo "==> Building the runtime tests for the arm64 Simulator"
xcodebuild build-for-testing \
  -workspace "$WORKSPACE" -scheme "$SCHEME" \
  -destination "$SIMULATOR" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  -quiet

# ML Kit looks for its models in the main bundle, which for a SwiftPM test
# target is the test runner -- so the bundles have to be dropped in beside it
# rather than declared as package resources (that would mean committing ~25MB
# of Google's models to this repo).
echo "==> Staging resource bundles into the test runner"
for xctest in "$DERIVED_DATA"/Build/Products/*-iphonesimulator/*.xctest; do
  cp -rf GoogleMLKit/*.bundle "$xctest/"
done

echo "==> Running ML Kit on the arm64 Simulator"
TEST_LOG="$DERIVED_DATA/runtime-tests.log"
if ! xcodebuild test-without-building \
  -workspace "$WORKSPACE" -scheme "$SCHEME" \
  -destination "$SIMULATOR" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO > "$TEST_LOG" 2>&1; then
  grep -E '✘|error:|Invalid model|recorded an issue' "$TEST_LOG" | tail -20 >&2
  echo "error: the runtime tests failed -- full log at $TEST_LOG" >&2
  exit 1
fi

# `test-without-building` exits 0 when it runs no tests at all, so the count
# has to be asserted or this check passes vacuously.
if ! grep -qE 'Test run with [1-9][0-9]* test' "$TEST_LOG"; then
  echo "error: no runtime tests ran -- full log at $TEST_LOG" >&2
  exit 1
fi
grep -E '✔ Test |Test run with' "$TEST_LOG"

echo "==> Launching the app on the Simulator"
DEVICE="${SIMULATOR##*name=}"
APP_SIM=$(find "$DERIVED_DATA/Build/Products" -maxdepth 2 -name 'Example.app' -path '*-iphonesimulator*' | head -1)
if [ -z "$APP_SIM" ]; then
  echo "error: no simulator build of Example.app" >&2
  exit 1
fi
APP_BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw "$APP_SIM/Info.plist")
xcrun simctl bootstatus "$DEVICE" -b > /dev/null 2>&1 || true
xcrun simctl install "$DEVICE" "$APP_SIM"
APP_PID=$(xcrun simctl launch --terminate-running-process "$DEVICE" "$APP_BUNDLE_ID" | awk '{print $NF}')
sleep 5
# Simulator apps are host processes, so this catches a launch-time crash.
if ! kill -0 "$APP_PID" 2> /dev/null; then
  echo "error: $APP_BUNDLE_ID died within 5s of launch" >&2
  xcrun simctl spawn "$DEVICE" log show --last 1m --predicate "process == \"Example\"" 2>/dev/null | tail -20 >&2
  exit 1
fi
echo "$APP_BUNDLE_ID still running (pid $APP_PID)"
xcrun simctl terminate "$DEVICE" "$APP_BUNDLE_ID" > /dev/null 2>&1 || true

echo "==> Archiving for device"
rm -rf "$ARCHIVE_PATH"
xcodebuild archive \
  -workspace "$WORKSPACE" -scheme "$SCHEME" \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  -quiet

APP=$(find "$ARCHIVE_PATH/Products/Applications" -maxdepth 1 -name '*.app' | head -1)
if [ -z "$APP" ]; then
  echo "error: no .app in the archive" >&2
  exit 1
fi

echo
echo "==> Archive contents"
echo "app binary: $(du -h "$APP/$(basename "$APP" .app)" | cut -f1)"

# Xcode embeds a stub framework bundle for every static framework it links, so
# the bundles themselves are expected. What must not appear is an SDK on
# Apple's "commonly used third-party SDK" list, which App Store Connect
# rejects with ITMS-91065 unless the binary carries a signature.
SIGNATURE_SCANNED='GoogleToolboxForMac|SSZipArchive'
if [ -d "$APP/Frameworks" ]; then
  echo "embedded framework bundles: $(ls "$APP/Frameworks" | wc -l | tr -d ' ')"
  if ls "$APP/Frameworks" | grep -qE "^($SIGNATURE_SCANNED)"; then
    echo "error: $(ls "$APP/Frameworks" | grep -E "^($SIGNATURE_SCANNED)" | tr '\n' ' ')is embedded -- ITMS-91065 will fire" >&2
    exit 1
  fi
else
  echo "embedded framework bundles: 0"
fi

# Everything must be linked statically. A dynamic reference means a framework
# was relinked as a dylib, which is what dead-strips the ML Kit model data.
if otool -L "$APP/$(basename "$APP" .app)" | grep -qE 'MLKit|MLImage|GoogleToolboxForMac|SSZipArchive'; then
  echo "error: ML Kit is linked dynamically:" >&2
  otool -L "$APP/$(basename "$APP" .app)" | grep -E 'MLKit|MLImage|GoogleToolboxForMac|SSZipArchive' >&2
  exit 1
fi

# Every bundle the release publishes has to reach the app, or the module that
# needs it throws at runtime on device even though the Simulator tests passed
# from the staged copies.
MISSING_BUNDLES=""
for bundle in GoogleMLKit/*.bundle; do
  [ -d "$APP/$(basename "$bundle")" ] || MISSING_BUNDLES="$MISSING_BUNDLES $(basename "$bundle")"
done
if [ -n "$MISSING_BUNDLES" ]; then
  echo "error: the archived app is missing model bundles:$MISSING_BUNDLES" >&2
  exit 1
fi
echo "ML Kit model bundles in the app: $(ls -d GoogleMLKit/*.bundle | wc -l | tr -d ' ')"

# The OCR model alone is ~58MB of data inside MLKitTextRecognitionCommon; if it
# were dead-stripped the app binary could not reach this size.
APP_BINARY_SIZE=$(stat -f%z "$APP/$(basename "$APP" .app)")
if [ "$APP_BINARY_SIZE" -lt 60000000 ]; then
  echo "error: app binary is only $APP_BINARY_SIZE bytes -- ML Kit model data looks dead-stripped" >&2
  exit 1
fi

echo
echo "All local archive checks passed."
