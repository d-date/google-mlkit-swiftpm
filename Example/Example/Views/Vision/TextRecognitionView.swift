import SwiftUI
import MLImage
import MLKitTextRecognition
import MLKitTextRecognitionChinese
import MLKitTextRecognitionDevanagari
import MLKitTextRecognitionJapanese
import MLKitTextRecognitionKorean
import MLKitVision

enum TextRecognitionLanguage: String, CaseIterable, Identifiable {
  case latin = "Latin"
  case chinese = "Chinese"
  case devanagari = "Devanagari"
  case japanese = "Japanese"
  case korean = "Korean"

  var id: String { rawValue }

  var sampleImage: String {
    switch self {
    case .latin: return "image_has_text"
    case .chinese: return "chinese"
    case .devanagari: return "devanagari"
    case .japanese: return "japanese"
    case .korean: return "korean"
    }
  }
}

struct TextRecognitionView: View {
  @State private var recognizedText: String = ""
  @State private var selectedLanguage: TextRecognitionLanguage = .latin

  var body: some View {
    VStack {
      Picker("Language", selection: $selectedLanguage) {
        ForEach(TextRecognitionLanguage.allCases) { language in
          Text(language.rawValue).tag(language)
        }
      }
      .pickerStyle(.segmented)
      .padding(.horizontal)

      BaseDetectionView(
        title: "Text Recognition",
        sampleImages: [selectedLanguage.sampleImage],
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
  }

  private func recognizeText(image: UIImage) async throws {
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    let result: MLKitTextRecognition.Text

    switch selectedLanguage {
    case .latin:
      let options = TextRecognizerOptions()
      let textRecognizer = TextRecognizer.textRecognizer(options: options)
      result = try await textRecognizer.process(visionImage)

    case .chinese:
      let options = ChineseTextRecognizerOptions()
      let textRecognizer = TextRecognizer.textRecognizer(options: options)
      result = try await textRecognizer.process(visionImage)

    case .devanagari:
      let options = DevanagariTextRecognizerOptions()
      let textRecognizer = TextRecognizer.textRecognizer(options: options)
      result = try await textRecognizer.process(visionImage)

    case .japanese:
      let options = JapaneseTextRecognizerOptions()
      let textRecognizer = TextRecognizer.textRecognizer(options: options)
      result = try await textRecognizer.process(visionImage)

    case .korean:
      let options = KoreanTextRecognizerOptions()
      let textRecognizer = TextRecognizer.textRecognizer(options: options)
      result = try await textRecognizer.process(visionImage)
    }

    recognizedText = result.text
  }
}

#Preview {
  NavigationStack {
    TextRecognitionView()
  }
}
