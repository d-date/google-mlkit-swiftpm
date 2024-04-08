source 'https://cdn.cocoapods.org/'

platform :ios, '12.0'

install! 'cocoapods', integrate_targets: false

target 'MLKit' do
  use_frameworks!
  pod 'GoogleMLKit/FaceDetection', '~> 4.0.0'
  pod 'GoogleMLKit/BarcodeScanning', '~> 4.0.0'
end

# Workaround for Xcode 14 beta
# post_install do |installer|
#   installer.pods_project.targets.each do |target|
#     if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
#       target.build_configurations.each do |config|
#           config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
#       end
#     end
#   end
# end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete('ARCHS')
    end
  end
end
