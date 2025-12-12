import AVFoundation
@_exported import MLKitSegmentationSelfie
import MLKitVision
import UIKit

public struct SelfieSegmentationClient {
  public var segmentFromImage: (UIImage, SegmenterOptions?) async throws -> SegmentationMask
  public var segmentFromBuffer: (CMSampleBuffer, AVCaptureDevice.Position, SegmenterOptions?) async throws -> SegmentationMask
}

public extension SelfieSegmentationClient {
  static var live = Self(segmentFromImage: { image, options in
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let segmenter = Segmenter.segmenter(options: options ?? SegmenterOptions())
    return try await segmenter.process(visionImage)
  }, segmentFromBuffer: { sampleBuffer, cameraPosition, options in
    let visionImage = VisionImage(buffer: sampleBuffer)
    visionImage.orientation = await imageOrientation(
      deviceOrientation: UIDevice.current.orientation,
      cameraPosition: cameraPosition)

    let segmenter = Segmenter.segmenter(options: options ?? SegmenterOptions())
    return try await segmenter.process(visionImage)
  })
}
