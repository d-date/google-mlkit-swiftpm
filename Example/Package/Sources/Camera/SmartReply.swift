import Foundation
@_exported import MLKitSmartReply

public struct SmartReplyClient {
  public var suggestReplies: ([TextMessage]) async throws -> [SmartReplySuggestion]
}

public extension SmartReplyClient {
  static var live = Self(suggestReplies: { messages in
    let smartReply = NaturalLanguage.naturalLanguage().smartReply()
    return try await smartReply.suggestReplies(for: messages)
  })
}
