source 'https://cdn.cocoapods.org/'

platform :ios, '15.5'

install! 'cocoapods', integrate_targets: false

target 'MLKit' do
  use_frameworks!
  pod 'GoogleMLKit/FaceDetection', '~> 7.0.0'
  pod 'GoogleMLKit/BarcodeScanning', '~> 7.0.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete('ARCHS')
    end
  end
end
