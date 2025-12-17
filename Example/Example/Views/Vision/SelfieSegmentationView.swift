import SwiftUI
import MLImage
import MLKitSegmentationSelfie
import MLKitVision

struct SelfieSegmentationView: View {
  @State private var segmentationMask: SegmentationMask?
  @State private var maskImage: UIImage?

  var body: some View {
    BaseDetectionView(
      title: "Selfie Segmentation",
      sampleImages: ["grace_hopper"],
      detectionHandler: segmentImage,
      resultView: {
        VStack(alignment: .leading) {
          if let mask = segmentationMask {
            Text("Segmentation mask generated")
              .font(.headline)

            Text("Width: \(CVPixelBufferGetWidth(mask.buffer)), Height: \(CVPixelBufferGetHeight(mask.buffer))")
              .font(.caption)
              .foregroundStyle(.secondary)

            if let maskImage {
              Image(uiImage: maskImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
                .clipShape(.rect(cornerRadius: 8))
            }
          } else {
            Text("No segmentation data")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      }
    )
  }

  private func segmentImage(image: UIImage) async throws {
    let options = SelfieSegmenterOptions()
    options.segmenterMode = .singleImage

    let segmenter = Segmenter.segmenter(options: options)
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    segmentationMask = try await segmenter.process(visionImage)

    if let mask = segmentationMask {
      maskImage = createMaskVisualization(from: mask)
    }
  }

  private func createMaskVisualization(from mask: SegmentationMask) -> UIImage? {
    let maskBuffer = mask.buffer

    CVPixelBufferLockBaseAddress(maskBuffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(maskBuffer, .readOnly) }

    let width = CVPixelBufferGetWidth(maskBuffer)
    let height = CVPixelBufferGetHeight(maskBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(maskBuffer)

    guard let baseAddress = CVPixelBufferGetBaseAddress(maskBuffer) else {
      return nil
    }

    let colorSpace = CGColorSpaceCreateDeviceGray()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

    guard let context = CGContext(
      data: baseAddress,
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: bytesPerRow,
      space: colorSpace,
      bitmapInfo: bitmapInfo.rawValue
    ),
    let cgImage = context.makeImage() else {
      return nil
    }

    return UIImage(cgImage: cgImage)
  }
}

#Preview {
  NavigationStack {
    SelfieSegmentationView()
  }
}
