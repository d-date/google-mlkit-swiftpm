import SwiftUI
import MLImage
import MLKitImageLabeling
import MLKitVision

struct ImageLabelingView: View {
  @State private var labels: [ImageLabel] = []

  var body: some View {
    BaseDetectionView(
      title: "Image Labeling",
      sampleImages: ["bird", "beach", "liberty"],
      detectionHandler: detectLabels,
      resultView: {
        ScrollView {
          VStack(alignment: .leading) {
            Text("Detected \(labels.count) label(s)")
              .font(.headline)

            ForEach(labels.enumerated().map { $0 }, id: \.offset) { index, label in
              VStack(alignment: .leading) {
                Text(label.text)
                  .font(.subheadline)
                  .bold()

                Text("Confidence: \(label.confidence, format: .percent.precision(.fractionLength(2)))")
                  .font(.caption)
                  .foregroundStyle(.secondary)

                Text("Index: \(label.index)")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
              .padding()
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(Color.gray.opacity(0.1))
              .clipShape(.rect(cornerRadius: 8))
            }
          }
        }
      }
    )
  }

  private func detectLabels(image: UIImage) async throws {
    let options = ImageLabelerOptions()
    options.confidenceThreshold = 0.4

    let labeler = ImageLabeler.imageLabeler(options: options)
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    labels = try await labeler.process(visionImage)
  }
}

#Preview {
  NavigationStack {
    ImageLabelingView()
  }
}
