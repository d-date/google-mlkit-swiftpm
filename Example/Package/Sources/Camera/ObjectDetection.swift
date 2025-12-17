import AVFoundation
@_exported import MLKitObjectDetection
import MLKitVision
import UIKit

public struct ObjectDetectionClient {
  public var detectObjectsFromImage: (UIImage, ObjectDetectorOptions?) async throws -> [Object]
  public var detectObjectsFromBuffer: (CMSampleBuffer, AVCaptureDevice.Position, ObjectDetectorOptions?) async throws -> [Object]
}

public extension ObjectDetectionClient {
  @MainActor static let live = Self(detectObjectsFromImage: { image, options in
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let objectDetector = ObjectDetector.objectDetector(options: options ?? ObjectDetectorOptions())
    return try await objectDetector.process(visionImage)
  }, detectObjectsFromBuffer: { sampleBuffer, cameraPosition, options in
    let visionImage = VisionImage(buffer: sampleBuffer)
    visionImage.orientation = await imageOrientation(
      deviceOrientation: UIDevice.current.orientation,
      cameraPosition: cameraPosition)

    let objectDetector = ObjectDetector.objectDetector(options: options ?? ObjectDetectorOptions())
    return try await objectDetector.process(visionImage)
  })
}
