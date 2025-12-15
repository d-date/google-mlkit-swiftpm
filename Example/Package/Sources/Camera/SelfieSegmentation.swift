import AVFoundation
@_exported import MLKitSegmentationSelfie
@_exported import MLKitSegmentationCommon
import MLKitVision
import UIKit

public struct SelfieSegmentationClient {
  public var segmentFromImage: (UIImage, SelfieSegmenterOptions?) async throws -> SegmentationMask
  public var segmentFromBuffer: (CMSampleBuffer, AVCaptureDevice.Position, SelfieSegmenterOptions?) async throws -> SegmentationMask
}

public extension SelfieSegmentationClient {
  @MainActor static let live = Self(segmentFromImage: { image, options in
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let segmenter = Segmenter.segmenter(options: options ?? SelfieSegmenterOptions())
    return try await segmenter.process(visionImage)
  }, segmentFromBuffer: { sampleBuffer, cameraPosition, options in
    let visionImage = VisionImage(buffer: sampleBuffer)
    visionImage.orientation = await imageOrientation(
      deviceOrientation: UIDevice.current.orientation,
      cameraPosition: cameraPosition)

    let segmenter = Segmenter.segmenter(options: options ?? SelfieSegmenterOptions())
    return try await segmenter.process(visionImage)
  })
}
