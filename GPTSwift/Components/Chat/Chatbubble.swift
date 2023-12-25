//
//  Chatbubble.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI

struct Chatbubble: View {
    let author: Author
    let messageType: MessageType
    var value: String
    
    var body: some View {
        HStack {
            if author.isUser {
                Spacer()
            }
            if author != .System {
                VStack(alignment: author.isUser ? .trailing : .leading) {
                    if messageType == .Text {
                        Text(LocalizedStringKey(value))
                            .textSelection(.enabled)
                            .foregroundStyle(.white)
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
                }
                .padding()
                .background() {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(foregroundColor())
                }
            }
            if !author.isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.trailing, author.isUser ? 0 : 15)
        .padding(.leading, author.isUser ? 15 : 0)
    }
    
    private func foregroundColor() -> Color {
        switch author {
        case .User:
            return .blue
        case .GPT:
            return .gray
        case .Error:
            return .red
        case .System:
            return .clear
        }
    }
}

#Preview {
    ScrollView {
        ForEach(MyMessage.MOCK) { message in
            ForEach(message.contents) { content in
                Chatbubble(author: message.author, messageType: content.type, value: content.value)
            }
        }
    }
}
