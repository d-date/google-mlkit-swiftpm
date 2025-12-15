import SwiftUI
import MLImage
import MLKitTextRecognitionKorean
import MLKitVision

struct TextRecognitionKoreanView: View {
  @State private var recognizedText: String = ""

  var body: some View {
    BaseDetectionView(
      title: "Text Recognition (Korean)",
      sampleImages: ["korean", "korean_sparse"],
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
    let options = KoreanTextRecognizerOptions()
    let textRecognizer = TextRecognizer.textRecognizer(options: options)
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let result = try await textRecognizer.process(visionImage)
    recognizedText = result.text
  }
}

#Preview {
  NavigationStack {
    TextRecognitionKoreanView()
  }
}
