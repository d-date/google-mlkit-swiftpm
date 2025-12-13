import AVFoundation
@_exported import MLKitTextRecognition
import MLKitVision
import UIKit

public struct TextRecognitionClient {
  public var recognizeTextFromImage: (UIImage) async throws -> Text
  public var recognizeTextFromBuffer: (CMSampleBuffer, AVCaptureDevice.Position) async throws -> Text
}

public extension TextRecognitionClient {
  static var live = Self(recognizeTextFromImage: { image in
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let textRecognizer = TextRecognizer.textRecognizer()
    return try await textRecognizer.process(visionImage)
  }, recognizeTextFromBuffer: { sampleBuffer, cameraPosition in
    let visionImage = VisionImage(buffer: sampleBuffer)
    visionImage.orientation = await imageOrientation(
      deviceOrientation: UIDevice.current.orientation,
      cameraPosition: cameraPosition)

    let textRecognizer = TextRecognizer.textRecognizer()
    return try await textRecognizer.process(visionImage)
  })
}
