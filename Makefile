PROJECT_ROOT=$(cd $(dirname $0); cd ..; pwd)
PODS_ROOT="./Pods"
PODS_PROJECT="$(PODS_ROOT)/Pods.xcodeproj"
SYMROOT="$(PODS_ROOT)/Build"
IPHONEOS_DEPLOYMENT_TARGET = 12.0

bootstrap-cocoapods:
	@bundle install
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
create-xcframework: bootstrap-builder build-cocoapods prepare-info-plist
	@rm -rf GoogleMLKit
	@xcodebuild -create-xcframework \
		-framework Pods/Pods/Build/Release-iphonesimulator/GoogleToolboxForMac/GoogleToolboxForMac.framework \
		-framework Pods/Pods/Build/Release-iphoneos/GoogleToolboxForMac/GoogleToolboxForMac.framework \
		-output GoogleMLKit/GoogleToolboxForMac.xcframework
	@xcodebuild -create-xcframework \
		-framework Pods/Pods/Build/Release-iphonesimulator/GoogleUtilitiesComponents/GoogleUtilitiesComponents.framework \
		-framework Pods/Pods/Build/Release-iphoneos/GoogleUtilitiesComponents/GoogleUtilitiesComponents.framework \
		-output GoogleMLKit/GoogleUtilitiesComponents.xcframework
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

archive: create-xcframework
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
	@cd ./GoogleMLKit \
	 && zip -r MLKitBarcodeScanning.xcframework.zip MLKitBarcodeScanning.xcframework \
	 && zip -r MLKitFaceDetection.xcframework.zip MLKitFaceDetection.xcframework \
	 && zip -r GoogleToolboxForMac.xcframework.zip GoogleToolboxForMac.xcframework \
	 && zip -r GoogleUtilitiesComponents.xcframework.zip GoogleUtilitiesComponents.xcframework \
	 && zip -r MLImage.xcframework.zip MLImage.xcframework \
	 && zip -r MLKitCommon.xcframework.zip MLKitCommon.xcframework \
	 && zip -r MLKitVision.xcframework.zip MLKitVision.xcframework
.PHONY:
run: archive
