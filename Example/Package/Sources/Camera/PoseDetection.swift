import AVFoundation
@_exported import MLKitPoseDetection
import MLKitVision
import UIKit

public struct PoseDetectionClient {
  public var detectPoseFromImage: (UIImage, PoseDetectorOptions?) async throws -> [Pose]
  public var detectPoseFromBuffer: (CMSampleBuffer, AVCaptureDevice.Position, PoseDetectorOptions?) async throws -> [Pose]
}

public extension PoseDetectionClient {
  @MainActor static let live = Self(detectPoseFromImage: { image, options in
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let poseDetector = PoseDetector.poseDetector(options: options ?? PoseDetectorOptions())
    return try await poseDetector.process(visionImage)
  }, detectPoseFromBuffer: { sampleBuffer, cameraPosition, options in
    let visionImage = VisionImage(buffer: sampleBuffer)
    visionImage.orientation = await imageOrientation(
      deviceOrientation: UIDevice.current.orientation,
      cameraPosition: cameraPosition)

    let poseDetector = PoseDetector.poseDetector(options: options ?? PoseDetectorOptions())
    return try await poseDetector.process(visionImage)
  })
}
