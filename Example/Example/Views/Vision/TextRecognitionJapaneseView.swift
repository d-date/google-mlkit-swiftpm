import SwiftUI
import MLImage
import MLKitTextRecognitionJapanese
import MLKitVision

struct TextRecognitionJapaneseView: View {
  @State private var recognizedText: String = ""

  var body: some View {
    BaseDetectionView(
      title: "Text Recognition (Japanese)",
      sampleImages: ["japanese", "japanese_sparse"],
      detectionHandler: recognizeText,
      resultView: {
        ScrollView {
          VStack(alignment: .leading) {
            Text("Recognized Text:")
              .font(.headline)

            Text(recognizedText.isEmpty ? "No text detected" : recognizedText)
              .font(.body)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding()
              .background(Color.gray.opacity(0.1))
              .clipShape(.rect(cornerRadius: 8))
          }
        }
      }
    )
  }

  private func recognizeText(image: UIImage) async throws {
    let options = JapaneseTextRecognizerOptions()
    let textRecognizer = TextRecognizer.textRecognizer(options: options)
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let result = try await textRecognizer.process(visionImage)
    recognizedText = result.text
  }
}

#Preview {
  NavigationStack {
    TextRecognitionJapaneseView()
  }
}
