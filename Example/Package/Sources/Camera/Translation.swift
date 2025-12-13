import Foundation
@_exported import MLKitTranslate

public struct TranslationClient {
  public var translate: (String, TranslateLanguage, TranslateLanguage) async throws -> String
  public var downloadModel: (TranslateLanguage) async throws -> Void
}

public extension TranslationClient {
  static var live = Self(translate: { text, sourceLanguage, targetLanguage in
    let options = TranslatorOptions(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
    let translator = Translator.translator(options: options)
    return try await translator.translate(text)
  }, downloadModel: { language in
    let options = TranslatorOptions(sourceLanguage: language, targetLanguage: language)
    let translator = Translator.translator(options: options)
    let conditions = ModelDownloadConditions(
      allowsCellularAccess: false,
      allowsBackgroundDownloading: true
    )
    try await translator.downloadModelIfNeeded(with: conditions)
  })
}
