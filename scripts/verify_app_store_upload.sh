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
#   * `asc auth login` credentials for the team that owns the app record
#   * an installed App Store provisioning profile named $PROFILE. Xcode's own
#     account is not used, so automatic signing cannot create one; make it with
#       asc certificates list
#       asc profiles create --name "$PROFILE" --profile-type IOS_APP_STORE \
#         --bundle <bundle-id-resource-id> --certificate <distribution-cert-id>
#       asc profiles download --id <profile-id> --output <path>
#       asc profiles local install --path <path>
#
# Usage: ./scripts/verify_app_store_upload.sh [--upload]

set -euo pipefail

WORKSPACE="Example/Example.xcworkspace"
SCHEME="Example"
BUNDLE_ID="${MLKIT_ASC_BUNDLE_ID:-com.d-date.google-mlkit-swiftpm}"
TEAM_ID="${MLKIT_ASC_TEAM_ID:-N5U649DS4Z}"
PROFILE="${MLKIT_ASC_PROFILE:-SwiftPM Binary Verify App Store}"
ARTIFACTS="${TMPDIR:-/tmp}/mlkit-appstore"
ARCHIVE="$ARTIFACTS/Example.xcarchive"
IPA="$ARTIFACTS/Example.ipa"
EXPORT_OPTIONS="$ARTIFACTS/ExportOptions.plist"
PACKAGE_BACKUP="$ARTIFACTS/Package.swift.orig"
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

if ! asc profiles local list --output json | grep -q "$PROFILE"; then
  echo "error: provisioning profile \"$PROFILE\" is not installed -- see the header" >&2
  exit 1
fi

KEY_ID="${MLKIT_ASC_KEY_ID:-$(asc auth status --output json |
  python3 -c 'import json,sys; print(next((c["keyId"] for c in json.load(sys.stdin).get("credentials", []) if c.get("isDefault")), ""))')}"
ISSUER_ID="${MLKIT_ASC_ISSUER_ID:-$(asc auth issuer-id)}"
if [ -z "$KEY_ID" ] || [ -z "$ISSUER_ID" ]; then
  echo "error: no default App Store Connect API credentials -- run 'asc auth login'" >&2
  exit 1
fi

KEY_FILE="$HOME/.appstoreconnect/private_keys/AuthKey_$KEY_ID.p8"
EXPORTED_KEY=false

cleanup() {
  if [ -f "$PACKAGE_BACKUP" ]; then
    cp "$PACKAGE_BACKUP" Package.swift
    echo "Restored Package.swift"
  fi
  rm -f "$PACKAGE_BACKUP"
  if [ "$EXPORTED_KEY" = true ]; then
    rm -f "$KEY_FILE"
    echo "Removed the staged API key"
  fi
  return 0
}
trap cleanup EXIT

mkdir -p "$ARTIFACTS"
cp Package.swift "$PACKAGE_BACKUP"

# altool only looks for its API key in a handful of directories, and the key
# may well sit somewhere else (asc keeps the path in the keychain entry, often
# still in ~/Downloads). Copy it into place for this run and take it back out
# afterwards rather than leaving a credential where it was not before.
if [ ! -f "$KEY_FILE" ]; then
  SOURCE_KEY=""
  for candidate in "$HOME/private_keys" "$HOME/.private_keys" "$HOME/Downloads" "$PWD/private_keys"; do
    if [ -f "$candidate/AuthKey_$KEY_ID.p8" ]; then
      SOURCE_KEY="$candidate/AuthKey_$KEY_ID.p8"
      break
    fi
  done
  if [ -z "$SOURCE_KEY" ]; then
    echo "error: AuthKey_$KEY_ID.p8 not found; put it in ~/.appstoreconnect/private_keys" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$KEY_FILE")"
  install -m 600 "$SOURCE_KEY" "$KEY_FILE"
  EXPORTED_KEY=true
fi

echo "==> Pointing Package.swift at local XCFrameworks"
ruby scripts/use_local_binaries.rb

echo "==> Refreshing the resource bundles the Example app carries"
mkdir -p Example/Example/Resources/Bundles
cp -rf GoogleMLKit/*.bundle Example/Example/Resources/Bundles/

# Signing settings are deliberately not passed here: a command-line build
# setting reaches every target in the graph, and SwiftPM's resource-bundle
# targets reject a provisioning profile outright. The distribution identity and
# profile are applied at export instead, which is per-app.
echo "==> Archiving $BUNDLE_ID build $BUILD_NUMBER"
asc xcode archive \
  --workspace "$WORKSPACE" --scheme "$SCHEME" \
  --configuration Release \
  --archive-path "$ARCHIVE" --overwrite \
  --xcodebuild-flag="PRODUCT_BUNDLE_IDENTIFIER=$BUNDLE_ID" \
  --xcodebuild-flag="CURRENT_PROJECT_VERSION=$BUILD_NUMBER" \
  --xcodebuild-flag="DEVELOPMENT_TEAM=$TEAM_ID" \
  --output table

echo "==> Exporting an App Store IPA"
cat > "$EXPORT_OPTIONS" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>teamID</key><string>$TEAM_ID</string>
  <key>signingStyle</key><string>manual</string>
  <key>signingCertificate</key><string>Apple Distribution</string>
  <key>provisioningProfiles</key>
  <dict><key>$BUNDLE_ID</key><string>$PROFILE</string></dict>
</dict>
</plist>
PLIST

asc xcode export \
  --archive-path "$ARCHIVE" --ipa-path "$IPA" --overwrite \
  --export-options "$EXPORT_OPTIONS" \
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
for bundle in GoogleMLKit/*.bundle; do
  if [ ! -d "$APP/$(basename "$bundle")" ]; then
    echo "error: the IPA is missing $(basename "$bundle")" >&2
    exit 1
  fi
done
echo "ML Kit model bundles: $(ls -d GoogleMLKit/*.bundle | wc -l | tr -d ' ')"

echo
echo "==> Validating with Apple"
asc xcode validate --ipa "$IPA" --api-key "$KEY_ID" --api-issuer "$ISSUER_ID" --output table

if [ "$UPLOAD" = false ]; then
  echo
  echo "Validation passed. Re-run with --upload to deliver the build and see"
  echo "App Store Connect's post-processing result, where ITMS-91065 appears."
  exit 0
fi

echo
echo "==> Uploading to App Store Connect and waiting for processing"
asc builds upload --app "$BUNDLE_ID" --ipa "$IPA" --wait --output table

echo
echo "Upload processed. Check App Store Connect for ITMS warnings on build $BUILD_NUMBER."
