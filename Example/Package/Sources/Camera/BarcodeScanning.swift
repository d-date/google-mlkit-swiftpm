import AVFoundation
import MLKitBarcodeScanning
import MLKitVision
import UIKit

public struct BarcodeScanningExample {
  public init() {}

  public func barcodeScan(image: UIImage, formats: BarcodeFormat) async throws -> [Barcode] {
    let barcodeOptions = BarcodeScannerOptions(formats: formats)
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let barcodeScanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)
    let features = try await barcodeScanner.process(visionImage)
    return features
  }

  public func barcodeScan(
    buffer sampleBuffer: CMSampleBuffer, cameraPosition: AVCaptureDevice.Position,
    formats: BarcodeFormat = .all
  ) async throws -> [Barcode] {
    let barcodeOptions = BarcodeScannerOptions(formats: formats)
    let visionImage = VisionImage(buffer: sampleBuffer)
    visionImage.orientation = await imageOrientation(
      deviceOrientation: UIDevice.current.orientation,
      cameraPosition: cameraPosition)

    let barcodeScanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)
    let features = try await barcodeScanner.process(visionImage)
    return features
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
