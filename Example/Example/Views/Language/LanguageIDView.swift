import SwiftUI
import MLKitLanguageID

struct LanguageIDView: View {
  @State private var inputText: String = "Hello, how are you?"
  @State private var detectedLanguage: String = ""
  @State private var confidence: Float = 0.0
  @State private var isDetecting = false

  let sampleTexts = [
    "Hello, how are you?",
    "こんにちは、お元気ですか？",
    "你好吗？",
    "Comment allez-vous?",
    "¿Cómo estás?",
    "Wie geht es dir?",
    "안녕하세요"
  ]

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading) {
          Text("Sample Texts")
            .font(.headline)

          ScrollView(.horizontal, showsIndicators: false) {
            HStack {
              ForEach(sampleTexts, id: \.self) { sample in
                Button {
                  inputText = sample
                } label: {
                  Text(sample)
                    .font(.caption)
                    .lineLimit(1)
                }
                .buttonStyle(.bordered)
              }
            }
            .scrollIndicators(.hidden)
          }

          Text("Input Text")
            .font(.headline)

          TextEditor(text: $inputText)
            .frame(height: 100)
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 8))

          Button {
            Task {
              await identifyLanguage()
            }
          } label: {
            if isDetecting {
              ProgressView()
            } else {
              Text("Identify Language")
            }
          }
          .buttonStyle(.borderedProminent)
          .disabled(inputText.isEmpty || isDetecting)

          if !detectedLanguage.isEmpty {
            VStack(alignment: .leading) {
              Text("Detected Language")
                .font(.headline)

              Text("Language: \(detectedLanguage)")
                .font(.body)

              Text("Confidence: \(confidence, format: .percent.precision(.fractionLength(2)))")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 8))
          }

          Spacer()
        }
      }
      .navigationTitle("Language Identification")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  private func identifyLanguage() async {
    isDetecting = true

    let languageId = LanguageIdentification.languageIdentification()

    do {
      let identifiedLanguage = try await languageId.identifyLanguage(for: inputText)
      detectedLanguage = identifiedLanguage
      confidence = 1.0
    } catch {
      detectedLanguage = "Unknown"
      confidence = 0.0
    }

    isDetecting = false
  }
}

#Preview {
  LanguageIDView()
}
