import SwiftUI
import MLImage
import MLKitBarcodeScanning
import MLKitVision

struct BarcodeScanningView: View {
  @State private var barcodes: [Barcode] = []

  var body: some View {
    BaseDetectionView(
      title: "Barcode Scanning",
      sampleImages: ["barcode_128", "qr_code"],
      detectionHandler: detectBarcodes,
      resultView: {
        ScrollView {
          VStack(alignment: .leading) {
            Text("Detected \(barcodes.count) barcode(s)")
              .font(.headline)

            ForEach(barcodes.enumerated().map { $0 }, id: \.offset) { index, barcode in
              VStack(alignment: .leading) {
                Text("Barcode \(index + 1)")
                  .font(.subheadline)
                  .bold()

                Text("Format: \(barcodeFormatString(barcode.format))")
                  .font(.caption)

                if let displayValue = barcode.displayValue {
                  Text("Value: \(displayValue)")
                    .font(.caption)
                }

                if let rawValue = barcode.rawValue {
                  Text("Raw: \(rawValue)")
                    .font(.caption)
                    .lineLimit(2)
                }
              }
              .padding()
              .background(Color.gray.opacity(0.1))
              .clipShape(.rect(cornerRadius: 8))
            }
          }
        }
      }
    )
  }

  private func detectBarcodes(image: UIImage) async throws {
    let options = BarcodeScannerOptions(formats: .all)
    let barcodeScanner = BarcodeScanner.barcodeScanner(options: options)

    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    barcodes = try await barcodeScanner.process(visionImage)
  }

  private func barcodeFormatString(_ format: BarcodeFormat) -> String {
    switch format {
    case .code128: return "Code 128"
    case .code39: return "Code 39"
    case .code93: return "Code 93"
    case .codaBar: return "Codabar"
    case .dataMatrix: return "Data Matrix"
    case .EAN13: return "EAN-13"
    case .EAN8: return "EAN-8"
    case .ITF: return "ITF"
    case .qrCode: return "QR Code"
    case .UPCA: return "UPC-A"
    case .UPCE: return "UPC-E"
    case .PDF417: return "PDF417"
    case .aztec: return "Aztec"
    default: return "Unknown"
    }
  }
}

#Preview {
  NavigationStack {
    BarcodeScanningView()
  }
}
