//
//  Chatbubble.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI
import MarkdownUI

struct Chatbubble: View {
    let author: Author
    let messageType: MessageType
    var value: String
    var chatState: ChatState
    var isLatest: Bool?
    
    @AppStorage("markdownToggle") var markdownToggle: Bool = true

    var body: some View {
        HStack {
            if author.isUser {
                Spacer()
            }
            if author != .System {
                VStack(alignment: author.isUser ? .trailing : .leading) {
                    if messageType == .Text {
                        if markdownToggle {
                            Markdown(value)
                                .textSelection(.enabled)
                                .markdownTheme(.customMarkdownTheme)
                                .markdownCodeSyntaxHighlighter(.syntaxHighlightingMarkdownUI())
                        } else {
                            Text(value)
                        }
                    } else {
                        if let data = Data(base64Encoded: value) {
#if os(iOS)
                            Image(uiImage: UIImage(data: data)!)
                                .resizable()
                                .scaledToFit()
#elseif os(macOS)
                            Image(nsImage: NSImage(data: data)!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400)
#endif
                        }
                    }
                    // Loading indicator
                    if chatState == .FetchingAPI && (isLatest ?? false) {
                        Image(systemName: "ellipsis")
                            .font(.title)
                            .symbolEffect(.pulse)
                            .padding(.top)
                    }
                }
                .padding()
                .background() {
                    // Background
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(bubbleForegroundColor())
                }
            }
            if !author.isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.trailing, author.isUser ? 0 : 30)
        .padding(.leading, author.isUser ? 30 : 0)
    }
    
    private func bubbleForegroundColor() -> Color {
        switch author {
        case .User:
            return .blue
        case .GPT:
            return .gray.opacity(0.7)
        case .Error:
            return .red
        case .System:
            return .clear
        }
    }
}

#if DEBUG
#Preview {
//    ScrollView {
//        ForEach(MyMessage.MOCK) { message in
//            ForEach(message.contents) { content in
//                Chatbubble(author: message.author, messageType: content.type, value: content.value)
//            }
//        }
//    }
    VStack {
        Chatbubble(author: .User, messageType: .Text, value: "Quod cupiditate voluptas. Veniam tenetur nam. A explicabo expedita a laudantium provident exercitationem numquam commodi repellat. Ratione ad aut laboriosam earum eaque. Rem praesentium occaecati dolore adipisci voluptatem nesciunt. Voluptas quidem beatae corrupti.", chatState: .Done)
        Chatbubble(author: .GPT, messageType: .Text, value: "Quod cupiditate voluptas. Veniam tenetur nam. A explicabo expedita a laudantium provident exercitationem numquam commodi repellat. Ratione ad aut laboriosam earum eaque. Rem praesentium occaecati dolore adipisci voluptatem nesciunt. Voluptas quidem beatae corrupti.", chatState: .Done)
        Chatbubble(author: .GPT, messageType: .Text, value: "Quod cupiditate voluptas. Veniam tenetur nam. A explicabo expedita a laudantium provident exercitationem numquam commodi repellat. Ratione ad aut laboriosam earum eaque. Rem praesentium occaecati dolore adipisci voluptatem nesciunt. Voluptas quidem beatae corrupti.", chatState: .FetchingAPI)
        Chatbubble(author: .Error, messageType: .Text, value: "Quod cupiditate voluptas. Veniam tenetur nam. A explicabo expedita a laudantium provident exercitationem numquam commodi repellat. Ratione ad aut laboriosam earum eaque. Rem praesentium occaecati dolore adipisci voluptatem nesciunt. Voluptas quidem beatae corrupti.", chatState: .Done)
    }
}
#endif
