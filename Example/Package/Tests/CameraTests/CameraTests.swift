import CoreImage
import Testing
import UIKit

@testable import Camera

/// Runtime smoke tests: these actually load ML Kit's models and run inference,
/// which is the only way to catch the failures that a successful link hides.
///
/// Text recognition is the important one. `MLKitTextRecognitionCommon` ships as
/// a Mach-O object file, and when Xcode relinks it as a dynamic framework the
/// ~58MB OCR model is dead-stripped; the app still builds and links, then
/// throws `MLKTextRecognizerInternalErrorCreationFailure` with "Invalid model
/// path." on the first recognition (issues #106/#109).
///
/// Running these on the Simulator also exercises the synthesised arm64
/// simulator slices: ML Kit ships no arm64 simulator code, so those binaries
/// are device code with a rewritten Mach-O platform. If that rewrite were
/// wrong, this is where it would crash.
///
/// Only modules whose models are linked into the binary are covered. Face
/// detection, image labeling, object detection, pose detection, selfie
/// segmentation and translation need resource bundles that SwiftPM cannot
/// carry inside a binary target, so they can only be exercised from an app
/// target that copies those bundles in.
@MainActor
struct CameraTests {
  @Test
  func recognisesTextFromAnImage() async throws {
    let expected = "HELLO MLKIT 12345"
    let text = try await TextRecognitionClient.live.recognizeTextFromImage(image(of: expected))

    #expect(text.text.replacingOccurrences(of: "\n", with: " ").contains("MLKIT"))
    #expect(!text.blocks.isEmpty)
  }

  @Test
  func scansABarcode() async throws {
    let payload = "MLKIT-SWIFTPM"
    let barcodes = try await BarcodeScanClient.live.barcodeScanFromImage(
      try barcode(of: payload), .code128)

    #expect(barcodes.map(\.rawValue) == [payload])
  }

  @Test
  func identifiesALanguage() async throws {
    let language = try await LanguageIdentificationClient.live.identifyLanguage(
      "Wie geht es dir heute?")

    #expect(language == "de")
  }

  // MARK: - Fixtures

  /// Draws text large enough for the OCR model to read without shipping an
  /// image fixture alongside the test bundle.
  private func image(of text: String) -> UIImage {
    let size = CGSize(width: 1000, height: 300)
    return UIGraphicsImageRenderer(size: size).image { context in
      UIColor.white.setFill()
      context.fill(CGRect(origin: .zero, size: size))
      (text as NSString).draw(
        at: CGPoint(x: 40, y: 100),
        withAttributes: [
          .font: UIFont.systemFont(ofSize: 90, weight: .semibold),
          .foregroundColor: UIColor.black,
        ])
    }
  }

  private func barcode(of payload: String) throws -> UIImage {
    let filter = CIFilter(name: "CICode128BarcodeGenerator")
    filter?.setValue(Data(payload.utf8), forKey: "inputMessage")
    let generated = try #require(filter?.outputImage)
    // ML Kit needs more than the generator's ~1pt-per-module output.
    let scaled = generated.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
    let context = CIContext()
    let cgImage = try #require(context.createCGImage(scaled, from: scaled.extent))
    return UIImage(cgImage: cgImage)
  }
}
