PODS_ROOT = ./Pods
PODS_PROJECT = $(PODS_ROOT)/Pods.xcodeproj
# xcodebuild resolves a relative SYMROOT against the project directory, so this
# lands in $(PODS_ROOT)/Pods/Build -- which is what $(BUILD_DIR) points at.
SYMROOT = $(PODS_ROOT)/Build
BUILD_DIR = $(PODS_ROOT)/Pods/Build
# Xcode 26 dropped support for deployment targets below 15.0.
IPHONEOS_DEPLOYMENT_TARGET = 15.0
OUTPUT_DIR = GoogleMLKit
STAGING_DIR = $(OUTPUT_DIR)/.staging
MAKE_XCFRAMEWORK = xcframework-maker/.build/release/make-xcframework

# Every recipe loop below ends its body with `|| exit 1`: a POSIX `for` loop
# exits with the status of its last command, so without it a mid-loop failure
# is swallowed and `make run` reports success with a release asset missing.
# (.SHELLFLAGS would be tidier but GNU Make 3.81, which macOS ships, ignores it.)

# Pods that ship pre-built fat frameworks. These are repackaged by
# xcframework-maker rather than compiled, and each one needs a matching
# Resources/<name>-Info.plist because ML Kit ships them without a usable one.
MLKIT_MODULES = \
	MLImage \
	MLKitCommon \
	MLKitVision \
	MLKitVisionKit \
	MLKitImageLabelingCommon \
	MLKitObjectDetectionCommon \
	MLKitPoseDetectionCommon \
	MLKitSegmentationCommon \
	MLKitTextRecognitionCommon \
	MLKitXenoCommon \
	MLKitNaturalLanguage \
	MLKitBarcodeScanning \
	MLKitFaceDetection \
	MLKitTextRecognition \
	MLKitTextRecognitionChinese \
	MLKitTextRecognitionDevanagari \
	MLKitTextRecognitionJapanese \
	MLKitTextRecognitionKorean \
	MLKitImageLabeling \
	MLKitImageLabelingCustom \
	MLKitObjectDetection \
	MLKitObjectDetectionCustom \
	MLKitPoseDetection \
	MLKitPoseDetectionAccurate \
	MLKitSegmentationSelfie \
	MLKitLanguageID \
	MLKitTranslate \
	MLKitSmartReply

# Pods compiled from source, so xcodebuild produces both SDK slices itself.
# These ship as library-type XCFrameworks (a static archive plus headers)
# rather than framework bundles: ML Kit links them but nobody imports them, and
# Xcode embeds a stub framework in the consumer app for every static framework
# bundle it links. An embedded copy of a "commonly used third-party SDK" is
# rejected with ITMS-91065 unless it carries a signature this repo cannot
# provide, so the bundle has to go.
SOURCE_MODULES = GoogleToolboxForMac SSZipArchive

bootstrap-cocoapods:
	@bundle install
	@bundle exec pod repo update
	@bundle exec pod install

bootstrap-builder:
	@git submodule update --init --recursive xcframework-maker
	@cd xcframework-maker && swift build -c release

build-cocoapods: bootstrap-cocoapods
	@xcodebuild -project "$(PODS_PROJECT)" \
	-sdk iphoneos \
	-configuration Release -alltargets \
	ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=NO SYMROOT="$(SYMROOT)" \
	CLANG_ENABLE_MODULE_DEBUGGING=NO \
	IPHONEOS_DEPLOYMENT_TARGET="$(IPHONEOS_DEPLOYMENT_TARGET)"
	@xcodebuild -project "$(PODS_PROJECT)" \
	-sdk iphonesimulator \
	-configuration Release -alltargets \
	ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=NO SYMROOT="$(SYMROOT)" \
	CLANG_ENABLE_MODULE_DEBUGGING=NO \
	IPHONEOS_DEPLOYMENT_TARGET="$(IPHONEOS_DEPLOYMENT_TARGET)"

# ML Kit's pre-built frameworks ship without a usable Info.plist; without this
# a SwiftPM consumer crashes at launch with "The bundle doesn't contain...".
prepare-info-plist:
	@for module in $(MLKIT_MODULES); do \
		cp -rf "./Resources/$$module-Info.plist" \
			"$(PODS_ROOT)/$$module/Frameworks/$$module.framework/Info.plist" || exit 1; \
	done

create-xcframework: bootstrap-builder build-cocoapods prepare-info-plist
	@rm -rf $(OUTPUT_DIR)
	@for module in $(SOURCE_MODULES); do \
		echo "Creating $$module.xcframework"; \
		for sdk in iphoneos iphonesimulator; do \
			staging="$(STAGING_DIR)/$$module/$$sdk"; \
			mkdir -p "$$staging" || exit 1; \
			cp "$(BUILD_DIR)/Release-$$sdk/$$module/$$module.framework/$$module" "$$staging/lib$$module.a" || exit 1; \
			cp -rf "$(BUILD_DIR)/Release-$$sdk/$$module/$$module.framework/Headers" "$$staging/Headers" || exit 1; \
		done; \
		xcodebuild -create-xcframework \
			-library "$(STAGING_DIR)/$$module/iphoneos/lib$$module.a" \
			-headers "$(STAGING_DIR)/$$module/iphoneos/Headers" \
			-library "$(STAGING_DIR)/$$module/iphonesimulator/lib$$module.a" \
			-headers "$(STAGING_DIR)/$$module/iphonesimulator/Headers" \
			-output "$(OUTPUT_DIR)/$$module.xcframework" >/dev/null || exit 1; \
	done
	@rm -rf $(STAGING_DIR)
	@for module in $(MLKIT_MODULES); do \
		echo "Creating $$module.xcframework"; \
		$(MAKE_XCFRAMEWORK) \
			-ios "$(PODS_ROOT)/$$module/Frameworks/$$module.framework" \
			-output $(OUTPUT_DIR) || exit 1; \
	done

# Injects the arm64 simulator slice and converts object-file binaries into `ar`
# archives. See scripts/postprocess_xcframeworks.rb for why both are needed.
postprocess: create-xcframework
	@IPHONEOS_DEPLOYMENT_TARGET="$(IPHONEOS_DEPLOYMENT_TARGET)" \
		ruby scripts/postprocess_xcframeworks.rb $(OUTPUT_DIR)

# SwiftPM cannot carry resource bundles inside a binary target, so every bundle
# ships as its own release asset for consumers to add to their app target.
#
# Pods/<module>/Resources/<Name>/ is the authoritative set: it is what each
# podspec declares as `resource_bundles`, and it includes the OCR, pose
# detection and selfie segmentation models that are *not* nested inside any
# framework. Shipping only the nested copies left text recognition failing at
# runtime with "Invalid model path." (issues #106/#109).
#
# The nested copies are scanned too. Their contents are identical, but ML Kit's
# SmartReply framework nests its bundle under a different name than the podspec
# key (PredictOnDevice_resource vs PredictOnDeviceResource), and earlier
# releases shipped the nested spelling.
copy-resource-bundle: create-xcframework
	@for module in $(MLKIT_MODULES); do \
		[ -d "$(PODS_ROOT)/$$module/Resources" ] || continue; \
		for resources in "$(PODS_ROOT)/$$module/Resources"/*/; do \
			cp -rf "$$resources" "$(OUTPUT_DIR)/$$(basename $$resources).bundle" || exit 1; \
		done; \
	done
	@find $(PODS_ROOT)/*/Frameworks -maxdepth 2 -name '*.bundle' -exec cp -rf {} $(OUTPUT_DIR)/ \; || exit 1
	@ls -d $(OUTPUT_DIR)/*.bundle | xargs -n1 basename

archive: postprocess copy-resource-bundle
	@cd $(OUTPUT_DIR) && for item in *.xcframework *.bundle; do \
		echo "Zipping $$item"; \
		zip -qr "$$item.zip" "$$item" || exit 1; \
	done

verify:
	@ruby scripts/check_product_closure.rb
	@ruby scripts/verify_build.rb
	@swift package dump-package >/dev/null && echo "Package.swift parses"

run: archive

.PHONY: bootstrap-cocoapods bootstrap-builder build-cocoapods prepare-info-plist \
	create-xcframework postprocess copy-resource-bundle archive verify run
