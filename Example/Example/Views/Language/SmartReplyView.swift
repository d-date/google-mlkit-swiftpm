import SwiftUI
import MLKitSmartReply

struct ConversationMessage: Identifiable {
  let id = UUID()
  let text: String
  let isLocalUser: Bool
  let timestamp: Date
}

struct SmartReplyView: View {
  @State private var messages: [ConversationMessage] = [
    ConversationMessage(text: "Hey, how are you?", isLocalUser: false, timestamp: Date().addingTimeInterval(-120)),
    ConversationMessage(text: "I'm doing great, thanks! How about you?", isLocalUser: true, timestamp: Date().addingTimeInterval(-60))
  ]
  @State private var inputText: String = ""
  @State private var suggestedReplies: [String] = []
  @State private var isGenerating = false

  var body: some View {
    NavigationStack {
      VStack {
        ScrollView {
          VStack(alignment: .leading) {
            ForEach(messages) { message in
              HStack {
                if message.isLocalUser {
                  Spacer()
                }

                VStack(alignment: message.isLocalUser ? .trailing : .leading) {
                  Text(message.text)
                    .padding()
                    .background(message.isLocalUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundStyle(message.isLocalUser ? .white : .primary)
                    .clipShape(.rect(cornerRadius: 12))

                  Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }

                if !message.isLocalUser {
                  Spacer()
                }
              }
            }
          }
        }

        if !suggestedReplies.isEmpty {
          VStack(alignment: .leading) {
            Text("Suggested Replies")
              .font(.caption)
              .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
              HStack {
                ForEach(suggestedReplies, id: \.self) { reply in
                  Button {
                    addMessage(reply, isLocal: true)
                  } label: {
                    Text(reply)
                      .font(.subheadline)
                  }
                  .buttonStyle(.bordered)
                }
              }
              .scrollIndicators(.hidden)
            }
          }
        }

        HStack {
          TextField("Type a message", text: $inputText)
            .textFieldStyle(.roundedBorder)

          Button {
            addMessage(inputText, isLocal: true)
            inputText = ""
          } label: {
            Image(systemName: "arrow.up.circle.fill")
              .font(.title2)
          }
          .disabled(inputText.isEmpty)

          Button {
            Task {
              await generateReplies()
            }
          } label: {
            if isGenerating {
              ProgressView()
            } else {
              Image(systemName: "sparkles")
                .font(.title2)
            }
          }
          .disabled(messages.isEmpty || isGenerating)
        }
      }
      .navigationTitle("Smart Reply")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Clear") {
            messages.removeAll()
            suggestedReplies.removeAll()
          }
        }
      }
      .onAppear {
        Task {
          await generateReplies()
        }
      }
    }
  }

  private func addMessage(_ text: String, isLocal: Bool) {
    let message = ConversationMessage(text: text, isLocalUser: isLocal, timestamp: Date())
    messages.append(message)

    Task {
      await generateReplies()
    }
  }

  private func generateReplies() async {
    guard !messages.isEmpty else {
      suggestedReplies = []
      return
    }

    isGenerating = true

    var conversation: [TextMessage] = []

    for message in messages {
      let textMessage = TextMessage(
        text: message.text,
        timestamp: TimeInterval(
          Int(message.timestamp.timeIntervalSince1970 * 1000)
        ),
        userID: message.isLocalUser ? "local" : "remote",
        isLocalUser: message.isLocalUser
      )
      conversation.append(textMessage)
    }

    do {
      let smartReply = SmartReply.smartReply()
      let result = try await smartReply.suggestReplies(for: conversation)

      switch result.status {
      case .success:
        suggestedReplies = result.suggestions.map { $0.text }
      case .notSupportedLanguage:
        suggestedReplies = []
      case .noReply:
        suggestedReplies = []
      default:
        suggestedReplies = []
      }
    } catch {
      suggestedReplies = []
    }

    isGenerating = false
  }
}

#Preview {
  SmartReplyView()
}
