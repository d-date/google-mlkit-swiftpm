import Foundation
@_exported import MLKitLanguageID

public struct LanguageIdentificationClient {
  public var identifyLanguage: (String) async throws -> String
  public var identifyPossibleLanguages: (String) async throws -> [IdentifiedLanguage]
}

public extension LanguageIdentificationClient {
  static var live = Self(identifyLanguage: { text in
    let languageId = LanguageIdentification.languageIdentification()
    return try await languageId.identifyLanguage(for: text)
  }, identifyPossibleLanguages: { text in
    let languageId = LanguageIdentification.languageIdentification()
    return try await languageId.identifyPossibleLanguages(for: text)
  })
}
