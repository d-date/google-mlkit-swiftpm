import AVFoundation
@_exported import MLKitBarcodeScanning
import MLKitVision
import UIKit

public struct BarcodeScanClient {
  public var barcodeScanFromImage: (UIImage, BarcodeFormat) async throws -> [Barcode]
  public var barcodeScanFromBuffer: (CMSampleBuffer, AVCaptureDevice.Position, BarcodeFormat) async throws -> [Barcode]
}

public extension BarcodeScanClient {
  @MainActor static let live = Self(barcodeScanFromImage: { image, formats in
    let barcodeOptions = BarcodeScannerOptions(formats: formats)
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let barcodeScanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)
    let features = try await barcodeScanner.process(visionImage)
    return features
  }, barcodeScanFromBuffer: { sampleBuffer, cameraPosition, formats in
    let barcodeOptions = BarcodeScannerOptions(formats: formats)
    let visionImage = VisionImage(buffer: sampleBuffer)
    visionImage.orientation = await imageOrientation(
      deviceOrientation: UIDevice.current.orientation,
      cameraPosition: cameraPosition)

    let barcodeScanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)
    let features = try await barcodeScanner.process(visionImage)
    return features
  })
}
