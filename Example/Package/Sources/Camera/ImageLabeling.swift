import AVFoundation
@_exported import MLKitImageLabeling
import MLKitVision
import UIKit

public struct ImageLabelingClient {
  public var labelImageFromImage: (UIImage, ImageLabelerOptions?) async throws -> [ImageLabel]
  public var labelImageFromBuffer: (CMSampleBuffer, AVCaptureDevice.Position, ImageLabelerOptions?) async throws -> [ImageLabel]
}

public extension ImageLabelingClient {
  @MainActor static let live = Self(labelImageFromImage: { image, options in
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let imageLabeler = ImageLabeler.imageLabeler(options: options ?? ImageLabelerOptions())
    return try await imageLabeler.process(visionImage)
  }, labelImageFromBuffer: { sampleBuffer, cameraPosition, options in
    let visionImage = VisionImage(buffer: sampleBuffer)
    visionImage.orientation = await imageOrientation(
      deviceOrientation: UIDevice.current.orientation,
      cameraPosition: cameraPosition)

    let imageLabeler = ImageLabeler.imageLabeler(options: options ?? ImageLabelerOptions())
    return try await imageLabeler.process(visionImage)
  })
}
