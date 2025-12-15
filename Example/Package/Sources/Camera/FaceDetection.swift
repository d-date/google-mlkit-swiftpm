import AVFoundation
@_exported import MLKitFaceDetection
import MLKitVision
import UIKit

public struct FaceDetectionClient {
  public var faceDetectionWithImage: (UIImage, FaceDetectorOptions) async throws -> [Face]
  public var faceDetectionWithBuffer: (CMSampleBuffer, AVCaptureDevice.Position, FaceDetectorOptions) async throws -> [Face]
}

public extension FaceDetectionClient {
  @MainActor static let live = Self.init(faceDetectionWithImage: { image, options in
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let faceDetector = FaceDetector.faceDetector(options: options)
    return try await faceDetector.process(visionImage)

  }, faceDetectionWithBuffer: { sampleBuffer, cameraPosition, options in
    let visionImage = VisionImage(buffer: sampleBuffer)
    visionImage.orientation = await imageOrientation(
      deviceOrientation: UIDevice.current.orientation,
      cameraPosition: cameraPosition)

    let faceDetector = FaceDetector.faceDetector(options: options)
    return try await faceDetector.process(visionImage)
  })
}
