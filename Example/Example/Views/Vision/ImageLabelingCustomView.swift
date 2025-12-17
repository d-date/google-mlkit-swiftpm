import SwiftUI
import MLImage
import MLKitCommon
import MLKitImageLabelingCustom
import MLKitImageLabelingCommon
import MLKitVision

struct ImageLabelingCustomView: View {
  @State private var labels: [ImageLabel] = []
  @State private var modelLoadError: String?

  var body: some View {
    BaseDetectionView(
      title: "Image Labeling (Custom)",
      sampleImages: ["bird"],
      detectionHandler: detectLabels,
      resultView: {
        ScrollView {
          VStack(alignment: .leading) {
            if let error = modelLoadError {
              Text("Model Error: \(error)")
                .foregroundStyle(.red)
                .font(.caption)
            }

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
    guard let modelPath = Bundle.main.path(forResource: "bird", ofType: "tflite") else {
      modelLoadError = "bird.tflite not found in bundle"
      throw NSError(domain: "ImageLabelingCustom", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file not found"])
    }

    let localModel = LocalModel(path: modelPath)
    let options = CustomImageLabelerOptions(localModel: localModel)
    options.confidenceThreshold = 0.4

    let labeler = ImageLabeler.imageLabeler(options: options)
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    labels = try await labeler.process(visionImage)
    modelLoadError = nil
  }
}

#Preview {
  NavigationStack {
    ImageLabelingCustomView()
  }
}
