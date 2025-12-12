PROJECT_ROOT=$(cd $(dirname $0); cd ..; pwd)
PODS_ROOT="./Pods"
PODS_PROJECT="$(PODS_ROOT)/Pods.xcodeproj"
SYMROOT="$(PODS_ROOT)/Build"
IPHONEOS_DEPLOYMENT_TARGET = 12.0

bootstrap-cocoapods:
	@bundle install
	@bundle exec pod repo update
	@bundle exec pod install

bootstrap-builder:
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

# copy-resource-bundle:
# 	@cp -rf "./Pods/Pods/Build/Release-iphoneos/MLKitFaceDetection/GoogleMVFaceDetectorResources.bundle" "./Sources/FaceDetection/GoogleMVFaceDetectorResources.bundle"
prepare-info-plist:
	@cp -rf "./Resources/MLKitCommon-Info.plist" "./Pods/MLKitCommon/Frameworks/MLKitCommon.framework/Info.plist"
	@cp -rf "./Resources/MLKitBarcodeScanning-Info.plist" "./Pods/MLKitBarcodeScanning/Frameworks/MLKitBarcodeScanning.framework/Info.plist"
	@cp -rf "./Resources/MLKitFaceDetection-Info.plist" "./Pods/MLKitFaceDetection/Frameworks/MLKitFaceDetection.framework/Info.plist"
	@cp -rf "./Resources/MLKitVision-Info.plist" "./Pods/MLKitVision/Frameworks/MLKitVision.framework/Info.plist"
	@cp -rf "./Resources/MLImage-Info.plist" "./Pods/MLImage/Frameworks/MLImage.framework/Info.plist"
	@cp -rf "./Resources/MLKitTextRecognition-Info.plist" "./Pods/MLKitTextRecognition/Frameworks/MLKitTextRecognition.framework/Info.plist"
	@cp -rf "./Resources/MLKitImageLabeling-Info.plist" "./Pods/MLKitImageLabeling/Frameworks/MLKitImageLabeling.framework/Info.plist"
	@cp -rf "./Resources/MLKitObjectDetection-Info.plist" "./Pods/MLKitObjectDetection/Frameworks/MLKitObjectDetection.framework/Info.plist"
	@cp -rf "./Resources/MLKitPoseDetection-Info.plist" "./Pods/MLKitPoseDetection/Frameworks/MLKitPoseDetection.framework/Info.plist"
	@cp -rf "./Resources/MLKitSegmentationSelfie-Info.plist" "./Pods/MLKitSegmentationSelfie/Frameworks/MLKitSegmentationSelfie.framework/Info.plist"
	@cp -rf "./Resources/MLKitLanguageID-Info.plist" "./Pods/MLKitLanguageID/Frameworks/MLKitLanguageID.framework/Info.plist"
	@cp -rf "./Resources/MLKitTranslate-Info.plist" "./Pods/MLKitTranslate/Frameworks/MLKitTranslate.framework/Info.plist"
	@cp -rf "./Resources/MLKitSmartReply-Info.plist" "./Pods/MLKitSmartReply/Frameworks/MLKitSmartReply.framework/Info.plist"
create-xcframework: bootstrap-builder build-cocoapods prepare-info-plist
	@rm -rf GoogleMLKit
	@xcodebuild -create-xcframework \
		-framework Pods/Pods/Build/Release-iphonesimulator/GoogleToolboxForMac/GoogleToolboxForMac.framework \
		-framework Pods/Pods/Build/Release-iphoneos/GoogleToolboxForMac/GoogleToolboxForMac.framework \
		-output GoogleMLKit/GoogleToolboxForMac.xcframework
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLImage/Frameworks/MLImage.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitCommon/Frameworks/MLKitCommon.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitVision/Frameworks/MLKitVision.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitBarcodeScanning/Frameworks/MLKitBarcodeScanning.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitFaceDetection/Frameworks/MLKitFaceDetection.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitTextRecognition/Frameworks/MLKitTextRecognition.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitImageLabeling/Frameworks/MLKitImageLabeling.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitObjectDetection/Frameworks/MLKitObjectDetection.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitPoseDetection/Frameworks/MLKitPoseDetection.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitSegmentationSelfie/Frameworks/MLKitSegmentationSelfie.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitLanguageID/Frameworks/MLKitLanguageID.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitTranslate/Frameworks/MLKitTranslate.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitSmartReply/Frameworks/MLKitSmartReply.framework \
	-output GoogleMLKit

copy-resource-bundle:
	@cp -rf "./Pods/MLKitFaceDetection/Frameworks/MLKitFaceDetection.framework/GoogleMVFaceDetectorResources.bundle" "./GoogleMLKit/GoogleMVFaceDetectorResources.bundle"

archive: create-xcframework copy-resource-bundle
	@cd ./GoogleMLKit/MLKitBarcodeScanning.xcframework/ios-arm64/MLKitBarcodeScanning.framework \
	 && mv MLKitBarcodeScanning MLKitBarcodeScanning.o \
	 && ar r MLKitBarcodeScanning MLKitBarcodeScanning.o \
	 && ranlib MLKitBarcodeScanning \
	 && rm MLKitBarcodeScanning.o
	@cd ./GoogleMLKit/MLKitBarcodeScanning.xcframework/ios-x86_64-simulator/MLKitBarcodeScanning.framework \
	 && mv MLKitBarcodeScanning MLKitBarcodeScanning.o \
	 && ar r MLKitBarcodeScanning MLKitBarcodeScanning.o \
	 && ranlib MLKitBarcodeScanning \
	 && rm MLKitBarcodeScanning.o
	@cd ./GoogleMLKit/MLKitFaceDetection.xcframework/ios-arm64/MLKitFaceDetection.framework \
	 && mv MLKitFaceDetection MLKitFaceDetection.o \
	 && ar r MLKitFaceDetection MLKitFaceDetection.o \
	 && ranlib MLKitFaceDetection \
	 && rm MLKitFaceDetection.o
	@cd ./GoogleMLKit/MLKitFaceDetection.xcframework/ios-x86_64-simulator/MLKitFaceDetection.framework \
	 && mv MLKitFaceDetection MLKitFaceDetection.o \
	 && ar r MLKitFaceDetection MLKitFaceDetection.o \
	 && ranlib MLKitFaceDetection \
	 && rm MLKitFaceDetection.o
	@cd ./GoogleMLKit/MLKitTextRecognition.xcframework/ios-arm64/MLKitTextRecognition.framework \
	 && mv MLKitTextRecognition MLKitTextRecognition.o \
	 && ar r MLKitTextRecognition MLKitTextRecognition.o \
	 && ranlib MLKitTextRecognition \
	 && rm MLKitTextRecognition.o
	@cd ./GoogleMLKit/MLKitTextRecognition.xcframework/ios-x86_64-simulator/MLKitTextRecognition.framework \
	 && mv MLKitTextRecognition MLKitTextRecognition.o \
	 && ar r MLKitTextRecognition MLKitTextRecognition.o \
	 && ranlib MLKitTextRecognition \
	 && rm MLKitTextRecognition.o
	@cd ./GoogleMLKit/MLKitImageLabeling.xcframework/ios-arm64/MLKitImageLabeling.framework \
	 && mv MLKitImageLabeling MLKitImageLabeling.o \
	 && ar r MLKitImageLabeling MLKitImageLabeling.o \
	 && ranlib MLKitImageLabeling \
	 && rm MLKitImageLabeling.o
	@cd ./GoogleMLKit/MLKitImageLabeling.xcframework/ios-x86_64-simulator/MLKitImageLabeling.framework \
	 && mv MLKitImageLabeling MLKitImageLabeling.o \
	 && ar r MLKitImageLabeling MLKitImageLabeling.o \
	 && ranlib MLKitImageLabeling \
	 && rm MLKitImageLabeling.o
	@cd ./GoogleMLKit/MLKitObjectDetection.xcframework/ios-arm64/MLKitObjectDetection.framework \
	 && mv MLKitObjectDetection MLKitObjectDetection.o \
	 && ar r MLKitObjectDetection MLKitObjectDetection.o \
	 && ranlib MLKitObjectDetection \
	 && rm MLKitObjectDetection.o
	@cd ./GoogleMLKit/MLKitObjectDetection.xcframework/ios-x86_64-simulator/MLKitObjectDetection.framework \
	 && mv MLKitObjectDetection MLKitObjectDetection.o \
	 && ar r MLKitObjectDetection MLKitObjectDetection.o \
	 && ranlib MLKitObjectDetection \
	 && rm MLKitObjectDetection.o
	@cd ./GoogleMLKit/MLKitPoseDetection.xcframework/ios-arm64/MLKitPoseDetection.framework \
	 && mv MLKitPoseDetection MLKitPoseDetection.o \
	 && ar r MLKitPoseDetection MLKitPoseDetection.o \
	 && ranlib MLKitPoseDetection \
	 && rm MLKitPoseDetection.o
	@cd ./GoogleMLKit/MLKitPoseDetection.xcframework/ios-x86_64-simulator/MLKitPoseDetection.framework \
	 && mv MLKitPoseDetection MLKitPoseDetection.o \
	 && ar r MLKitPoseDetection MLKitPoseDetection.o \
	 && ranlib MLKitPoseDetection \
	 && rm MLKitPoseDetection.o
	@cd ./GoogleMLKit/MLKitSegmentationSelfie.xcframework/ios-arm64/MLKitSegmentationSelfie.framework \
	 && mv MLKitSegmentationSelfie MLKitSegmentationSelfie.o \
	 && ar r MLKitSegmentationSelfie MLKitSegmentationSelfie.o \
	 && ranlib MLKitSegmentationSelfie \
	 && rm MLKitSegmentationSelfie.o
	@cd ./GoogleMLKit/MLKitSegmentationSelfie.xcframework/ios-x86_64-simulator/MLKitSegmentationSelfie.framework \
	 && mv MLKitSegmentationSelfie MLKitSegmentationSelfie.o \
	 && ar r MLKitSegmentationSelfie MLKitSegmentationSelfie.o \
	 && ranlib MLKitSegmentationSelfie \
	 && rm MLKitSegmentationSelfie.o
	@cd ./GoogleMLKit/MLKitLanguageID.xcframework/ios-arm64/MLKitLanguageID.framework \
	 && mv MLKitLanguageID MLKitLanguageID.o \
	 && ar r MLKitLanguageID MLKitLanguageID.o \
	 && ranlib MLKitLanguageID \
	 && rm MLKitLanguageID.o
	@cd ./GoogleMLKit/MLKitLanguageID.xcframework/ios-x86_64-simulator/MLKitLanguageID.framework \
	 && mv MLKitLanguageID MLKitLanguageID.o \
	 && ar r MLKitLanguageID MLKitLanguageID.o \
	 && ranlib MLKitLanguageID \
	 && rm MLKitLanguageID.o
	@cd ./GoogleMLKit/MLKitTranslate.xcframework/ios-arm64/MLKitTranslate.framework \
	 && mv MLKitTranslate MLKitTranslate.o \
	 && ar r MLKitTranslate MLKitTranslate.o \
	 && ranlib MLKitTranslate \
	 && rm MLKitTranslate.o
	@cd ./GoogleMLKit/MLKitTranslate.xcframework/ios-x86_64-simulator/MLKitTranslate.framework \
	 && mv MLKitTranslate MLKitTranslate.o \
	 && ar r MLKitTranslate MLKitTranslate.o \
	 && ranlib MLKitTranslate \
	 && rm MLKitTranslate.o
	@cd ./GoogleMLKit/MLKitSmartReply.xcframework/ios-arm64/MLKitSmartReply.framework \
	 && mv MLKitSmartReply MLKitSmartReply.o \
	 && ar r MLKitSmartReply MLKitSmartReply.o \
	 && ranlib MLKitSmartReply \
	 && rm MLKitSmartReply.o
	@cd ./GoogleMLKit/MLKitSmartReply.xcframework/ios-x86_64-simulator/MLKitSmartReply.framework \
	 && mv MLKitSmartReply MLKitSmartReply.o \
	 && ar r MLKitSmartReply MLKitSmartReply.o \
	 && ranlib MLKitSmartReply \
	 && rm MLKitSmartReply.o
	@cd ./GoogleMLKit \
	 && zip -r MLKitBarcodeScanning.xcframework.zip MLKitBarcodeScanning.xcframework \
	 && zip -r MLKitFaceDetection.xcframework.zip MLKitFaceDetection.xcframework \
	 && zip -r MLKitTextRecognition.xcframework.zip MLKitTextRecognition.xcframework \
	 && zip -r MLKitImageLabeling.xcframework.zip MLKitImageLabeling.xcframework \
	 && zip -r MLKitObjectDetection.xcframework.zip MLKitObjectDetection.xcframework \
	 && zip -r MLKitPoseDetection.xcframework.zip MLKitPoseDetection.xcframework \
	 && zip -r MLKitSegmentationSelfie.xcframework.zip MLKitSegmentationSelfie.xcframework \
	 && zip -r MLKitLanguageID.xcframework.zip MLKitLanguageID.xcframework \
	 && zip -r MLKitTranslate.xcframework.zip MLKitTranslate.xcframework \
	 && zip -r MLKitSmartReply.xcframework.zip MLKitSmartReply.xcframework \
	 && zip -r GoogleToolboxForMac.xcframework.zip GoogleToolboxForMac.xcframework \
	 && zip -r MLImage.xcframework.zip MLImage.xcframework \
	 && zip -r MLKitCommon.xcframework.zip MLKitCommon.xcframework \
	 && zip -r MLKitVision.xcframework.zip MLKitVision.xcframework \
	 && zip -r GoogleMVFaceDetectorResources.bundle.zip GoogleMVFaceDetectorResources.bundle
.PHONY:
run: archive
