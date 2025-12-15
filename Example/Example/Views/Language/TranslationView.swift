import SwiftUI
import MLKitTranslate

struct TranslationView: View {
  @State private var inputText: String = "Hello, how are you?"
  @State private var translatedText: String = ""
  @State private var sourceLanguage: TranslateLanguage = .english
  @State private var targetLanguage: TranslateLanguage = .japanese
  @State private var isTranslating = false
  @State private var isDownloadingModel = false
  @State private var errorMessage: String?

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading) {
          Text("Source Language")
            .font(.headline)

          Picker("Source", selection: $sourceLanguage) {
            Text("English").tag(TranslateLanguage.english)
            Text("Japanese").tag(TranslateLanguage.japanese)
            Text("Chinese").tag(TranslateLanguage.chinese)
            Text("Korean").tag(TranslateLanguage.korean)
            Text("Spanish").tag(TranslateLanguage.spanish)
            Text("French").tag(TranslateLanguage.french)
          }
          .pickerStyle(.menu)

          Text("Target Language")
            .font(.headline)

          Picker("Target", selection: $targetLanguage) {
            Text("English").tag(TranslateLanguage.english)
            Text("Japanese").tag(TranslateLanguage.japanese)
            Text("Chinese").tag(TranslateLanguage.chinese)
            Text("Korean").tag(TranslateLanguage.korean)
            Text("Spanish").tag(TranslateLanguage.spanish)
            Text("French").tag(TranslateLanguage.french)
          }
          .pickerStyle(.menu)

          Text("Input Text")
            .font(.headline)

          TextEditor(text: $inputText)
            .frame(height: 100)
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 8))

          Button {
            Task {
              await translate()
            }
          } label: {
            if isTranslating {
              ProgressView()
            } else if isDownloadingModel {
              HStack {
                ProgressView()
                Text("Downloading model...")
              }
            } else {
              Text("Translate")
            }
          }
          .buttonStyle(.borderedProminent)
          .disabled(inputText.isEmpty || isTranslating || isDownloadingModel)

          if let error = errorMessage {
            Text(error)
              .foregroundStyle(.red)
              .font(.caption)
          }

          if !translatedText.isEmpty {
            VStack(alignment: .leading) {
              Text("Translation")
                .font(.headline)

              Text(translatedText)
                .font(.body)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 8))
          }

          Spacer()
        }
      }
      .navigationTitle("Translation")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  private func translate() async {
    errorMessage = nil
    isTranslating = true

    let options = TranslatorOptions(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
    let translator = Translator.translator(options: options)

    let conditions = ModelDownloadConditions(
      allowsCellularAccess: false,
      allowsBackgroundDownloading: true
    )

    do {
      isDownloadingModel = true
      try await translator.downloadModelIfNeeded(with: conditions)
      isDownloadingModel = false

      translatedText = try await translator.translate(inputText)
    } catch {
      errorMessage = "Translation failed: \(error.localizedDescription)"
      translatedText = ""
      isDownloadingModel = false
    }

    isTranslating = false
  }
}

#Preview {
  TranslationView()
}
