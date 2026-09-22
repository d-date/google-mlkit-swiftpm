#!/bin/bash
#
# Archives the Example app with distribution signing, validates the IPA with
# Apple, and optionally delivers it to App Store Connect.
#
# This exists because of ITMS-91065 ("Missing signature", issue #102): App
# Store Connect raises it during post-upload processing, not during a local
# export and not during `altool --validate-app`. Confirming that class of
# problem is gone needs a real delivery, so the upload is opt-in and the
# validation runs either way.
#
# Requires:
#   * GoogleMLKit/ from `make run`
#   * an App Store Connect app record for $BUNDLE_ID
#   * an Apple Distribution certificate in the keychain
#   * `asc auth login` credentials, and the matching .p8 under
#     ~/.appstoreconnect/private_keys/ so xcodebuild can create the profile
#
# Usage: ./scripts/verify_app_store_upload.sh [--upload]

set -euo pipefail

WORKSPACE="Example/Example.xcworkspace"
SCHEME="Example"
BUNDLE_ID="${MLKIT_ASC_BUNDLE_ID:-com.d-date.google-mlkit-swiftpm}"
TEAM_ID="${MLKIT_ASC_TEAM_ID:-N5U649DS4Z}"
ARTIFACTS="${TMPDIR:-/tmp}/mlkit-appstore"
ARCHIVE="$ARTIFACTS/Example.xcarchive"
IPA="$ARTIFACTS/Example.ipa"
# App Store Connect rejects a build number it has already seen.
BUILD_NUMBER="${MLKIT_ASC_BUILD_NUMBER:-$(date +%y%m%d%H%M)}"

UPLOAD=false
if [ "${1:-}" = "--upload" ]; then
  UPLOAD=true
elif [ -n "${1:-}" ]; then
  echo "usage: $0 [--upload]" >&2
  exit 1
fi

if [ ! -d GoogleMLKit ]; then
  echo "error: GoogleMLKit/ not found -- run 'make run' first" >&2
  exit 1
fi

KEY_PATH="${MLKIT_ASC_KEY_PATH:-$(find ~/.appstoreconnect/private_keys -name 'AuthKey_*.p8' 2>/dev/null | head -1)}"
if [ -z "$KEY_PATH" ]; then
  echo "error: no AuthKey_*.p8 under ~/.appstoreconnect/private_keys" >&2
  exit 1
fi
KEY_ID="${MLKIT_ASC_KEY_ID:-$(basename "$KEY_PATH" .p8 | sed 's/^AuthKey_//')}"
ISSUER_ID="${MLKIT_ASC_ISSUER_ID:-$(asc auth issuer-id)}"

# Restore from a copy rather than with `git checkout`: Package.swift normally
# has uncommitted changes while a fix is being verified.
PACKAGE_BACKUP="${TMPDIR:-/tmp}/Package.swift.appstore-orig"
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
mkdir -p Example/Example/Resources/Bundles
cp -rf GoogleMLKit/*.bundle Example/Example/Resources/Bundles/

mkdir -p "$ARTIFACTS"

echo "==> Archiving $BUNDLE_ID build $BUILD_NUMBER for distribution"
asc xcode archive \
  --workspace "$WORKSPACE" --scheme "$SCHEME" \
  --configuration Release \
  --archive-path "$ARCHIVE" --overwrite \
  --xcodebuild-flag="PRODUCT_BUNDLE_IDENTIFIER=$BUNDLE_ID" \
  --xcodebuild-flag="CURRENT_PROJECT_VERSION=$BUILD_NUMBER" \
  --xcodebuild-flag="DEVELOPMENT_TEAM=$TEAM_ID" \
  --xcodebuild-flag=-allowProvisioningUpdates \
  --xcodebuild-flag=-authenticationKeyPath --xcodebuild-flag="$KEY_PATH" \
  --xcodebuild-flag=-authenticationKeyID --xcodebuild-flag="$KEY_ID" \
  --xcodebuild-flag=-authenticationKeyIssuerID --xcodebuild-flag="$ISSUER_ID" \
  --output table

echo "==> Exporting an App Store IPA"
asc xcode export \
  --archive-path "$ARCHIVE" --ipa-path "$IPA" --overwrite \
  --method app-store-connect --signing-style automatic --team-id "$TEAM_ID" \
  --xcodebuild-flag=-allowProvisioningUpdates \
  --xcodebuild-flag=-authenticationKeyPath --xcodebuild-flag="$KEY_PATH" \
  --xcodebuild-flag=-authenticationKeyID --xcodebuild-flag="$KEY_ID" \
  --xcodebuild-flag=-authenticationKeyIssuerID --xcodebuild-flag="$ISSUER_ID" \
  --output table

echo
echo "==> IPA contents"
IPA_DIR="$ARTIFACTS/unpacked"
rm -rf "$IPA_DIR"
unzip -q "$IPA" -d "$IPA_DIR"
APP=$(find "$IPA_DIR/Payload" -maxdepth 1 -name '*.app' | head -1)
echo "app binary: $(du -h "$APP/$(basename "$APP" .app)" | cut -f1)"
if [ -d "$APP/Frameworks" ]; then
  echo "embedded framework bundles: $(ls "$APP/Frameworks" | wc -l | tr -d ' ')"
  if ls "$APP/Frameworks" | grep -qE '^(GoogleToolboxForMac|SSZipArchive)'; then
    echo "error: an SDK on Apple's commonly-used list is embedded -- ITMS-91065 will fire" >&2
    exit 1
  fi
fi
echo "bundled ML Kit models: $(ls "$APP" | grep -c '\.bundle$')"

echo
echo "==> Validating with Apple"
asc xcode validate --ipa "$IPA" --api-key "$KEY_ID" --api-issuer "$ISSUER_ID" --output table

if [ "$UPLOAD" = false ]; then
  echo
  echo "Validation passed. Re-run with --upload to deliver the build and see"
  echo "App Store Connect's post-processing result (where ITMS-91065 appears)."
  exit 0
fi

echo
echo "==> Uploading to App Store Connect and waiting for processing"
asc builds upload --app "$BUNDLE_ID" --ipa "$IPA" --wait --output table

echo
echo "Upload processed. Check App Store Connect for ITMS warnings on build $BUILD_NUMBER."
