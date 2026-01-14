#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

# Template for Info.plist
PLIST_TEMPLATE = <<~PLIST
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
  <key>CFBundleName</key>
  <string>%{bundle_name}</string>
  <key>DTSSDKName</key>
  <string>iphoneos17.4</string>
  <key>DTXcode</key>
  <string>1530</string>
  <key>DTSDKBuild</key>
  <string>21E210</string>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>BuildMachineOSBuild</key>
  <string>23D60</string>
  <key>DTPlatformName</key>
  <string>iphoneos</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  \t<string>%{version}</string>
  <key>CFBundleSupportedPlatforms</key>
  <array>
  <string>iPhoneOS</string>
  </array>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleExecutable</key>
  <string>%{bundle_name}</string>
  <key>DTCompiler</key>
  <string>com.apple.compilers.llvm.clang.1_0</string>
  <key>UIRequiredDeviceCapabilities</key>
  <array>
  <string>arm64</string>
  </array>
  <key>MinimumOSVersion</key>
  <string>12.0</string>
  <key>CFBundleSignature</key>
  <string>????</string>
  <key>DTPlatformVersion</key>
  <string>17.4</string>
  <key>DTXcodeBuild</key>
  <string>15E204a</string>
  <key>DTPlatformBuild</key>
  <string>21E210</string>
  <key>CFBundleIdentifier</key>
  <string>com.google.firebase.mlkit.%{bundle_id_suffix}</string>
  </dict>
  </plist>
PLIST

# Map framework name to bundle identifier suffix
BUNDLE_ID_SUFFIXES = {
  'MLKitImageLabeling' => 'imagelabeling',
  'MLKitImageLabelingCommon' => 'imagelabelingcommon',
  'MLKitImageLabelingCustom' => 'imagelabelingcustom',
  'MLKitObjectDetection' => 'objectdetection',
  'MLKitObjectDetectionCommon' => 'objectdetectioncommon',
  'MLKitObjectDetectionCustom' => 'objectdetectioncustom',
  'MLKitPoseDetection' => 'posedetection',
  'MLKitPoseDetectionAccurate' => 'posedetectionaccurate',
  'MLKitPoseDetectionCommon' => 'posedetectioncommon',
  'MLKitSegmentationCommon' => 'segmentationcommon',
  'MLKitSegmentationSelfie' => 'segmentationselfie',
  'MLKitTextRecognition' => 'textrecognition',
  'MLKitTextRecognitionChinese' => 'textrecognitionchinese',
  'MLKitTextRecognitionCommon' => 'textrecognitioncommon',
  'MLKitTextRecognitionDevanagari' => 'textrecognitiondevanagari',
  'MLKitTextRecognitionJapanese' => 'textrecognitionjapanese',
  'MLKitTextRecognitionKorean' => 'textrecognitionkorean',
  'MLKitVisionKit' => 'visionkit',
  'MLKitXenoCommon' => 'xenocommon'
}.freeze

def create_info_plist(framework_name, version)
  bundle_id_suffix = BUNDLE_ID_SUFFIXES[framework_name]
  unless bundle_id_suffix
    puts "Warning: Unknown framework #{framework_name}, skipping"
    return
  end

  output_file = "Resources/#{framework_name}-Info.plist"
  
  if File.exist?(output_file)
    puts "Skipping #{output_file} (already exists)"
    return
  end

  content = PLIST_TEMPLATE % {
    bundle_name: framework_name,
    version: version,
    bundle_id_suffix: bundle_id_suffix
  }

  File.write(output_file, content)
  puts "Created #{output_file}"
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  # Parse Podfile.lock for versions
  unless File.exist?('Podfile.lock')
    puts "Error: Podfile.lock not found"
    exit 1
  end

  podfile_lock = File.read('Podfile.lock')
  versions = {}

  podfile_lock.scan(/^  - ([^\/\s]+)(?:\/[^\s]+)?\s+\(([^)]+)\):?/) do |name, version_str|
    if match = version_str.match(/([\d.\-\w]+)/)
      versions[name] = match[1]
    end
  end

  puts "Creating Info.plist files for new frameworks..."
  BUNDLE_ID_SUFFIXES.keys.each do |framework_name|
    version = versions[framework_name] || '1.0.0'
    create_info_plist(framework_name, version)
  end

  puts "\n✓ Info.plist creation completed"
end
