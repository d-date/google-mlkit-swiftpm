source 'https://cdn.cocoapods.org/'

platform :ios, '15.5'

install! 'cocoapods', integrate_targets: false

target 'MLKit' do
  use_frameworks!
  # Existing modules
  pod 'GoogleMLKit/FaceDetection', '~> 9.0.0'
  pod 'GoogleMLKit/BarcodeScanning', '~> 9.0.0'
  # Vision modules - Text Recognition
  pod 'GoogleMLKit/TextRecognition', '~> 9.0.0'
  pod 'GoogleMLKit/TextRecognitionChinese', '~> 9.0.0'
  pod 'GoogleMLKit/TextRecognitionDevanagari', '~> 9.0.0'
  pod 'GoogleMLKit/TextRecognitionJapanese', '~> 9.0.0'
  pod 'GoogleMLKit/TextRecognitionKorean', '~> 9.0.0'
  # Vision modules - Image Labeling
  pod 'GoogleMLKit/ImageLabeling', '~> 9.0.0'
  pod 'GoogleMLKit/ImageLabelingCustom', '~> 9.0.0'
  # Vision modules - Object Detection
  pod 'GoogleMLKit/ObjectDetection', '~> 9.0.0'
  pod 'GoogleMLKit/ObjectDetectionCustom', '~> 9.0.0'
  # Vision modules - Pose Detection
  pod 'GoogleMLKit/PoseDetection', '~> 9.0.0'
  pod 'GoogleMLKit/PoseDetectionAccurate', '~> 9.0.0'
  # Vision modules - Selfie Segmentation
  pod 'GoogleMLKit/SelfieSegmentation', '~> 9.0.0'
  # Language modules
  pod 'GoogleMLKit/LanguageID', '~> 9.0.0'
  pod 'GoogleMLKit/Translate', '~> 9.0.0'
  pod 'GoogleMLKit/SmartReply', '~> 9.0.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete('ARCHS')
    end
  end
end
