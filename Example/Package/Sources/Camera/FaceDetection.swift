import AVFoundation
import MLKitBarcodeScanning
import MLKitFaceDetection
import MLKitVision
import UIKit

public struct FaceDetectionExample {
  public init() {}

  var options: FaceDetectorOptions {
    // High-accuracy landmark detection and face classification
    let options = FaceDetectorOptions()
    options.performanceMode = .accurate
    options.landmarkMode = .all
    options.classificationMode = .all

    // Real-time contour detection of multiple faces
    // options.contourMode = .all
    return options
  }

  public func faceDetection(image: UIImage) async throws -> [Face] {
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let faceDetector = FaceDetector.faceDetector(options: options)
    return try await faceDetector.process(visionImage)
  }

  public func faceDetection(
    buffer sampleBuffer: CMSampleBuffer, cameraPosition: AVCaptureDevice.Position
  ) async throws -> [Face] {
    let visionImage = VisionImage(buffer: sampleBuffer)
    visionImage.orientation = await imageOrientation(
      deviceOrientation: UIDevice.current.orientation,
      cameraPosition: cameraPosition)

    let faceDetector = FaceDetector.faceDetector(options: options)
    return try await faceDetector.process(visionImage)
  }

  func imageOrientation(
    deviceOrientation: UIDeviceOrientation, cameraPosition: AVCaptureDevice.Position
  ) -> UIImage.Orientation {
    switch deviceOrientation {
    case .portrait:
      return cameraPosition == .front ? .leftMirrored : .right
    case .landscapeLeft:
      return cameraPosition == .front ? .downMirrored : .up
    case .portraitUpsideDown:
      return cameraPosition == .front ? .rightMirrored : .left
    case .landscapeRight:
      return cameraPosition == .front ? .upMirrored : .down
    case .faceDown, .faceUp, .unknown:
      return .up
    @unknown default:
      fatalError()
    }
  }
}
