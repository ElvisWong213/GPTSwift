//
//  ChatView.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI
import SwiftData

struct ChatView: View {
    @State private var viewModel: ChatViewModel
    
    init(modelContext: ModelContext, chat: Chat) {
        self._viewModel = State(initialValue: ChatViewModel(modelContext: modelContext, chat: chat))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.chat.messages.sorted(by: { $0.timestamp < $1.timestamp } )) { message in
                        ForEach(message.contents) { content in
                            Chatbubble(author: message.author, messageType: content.type, value: content.value)
                        }
                    }
                    if !viewModel.errorMessage.isEmpty {
                        Chatbubble(author: .Error, messageType: .Text, value: viewModel.errorMessage)
                    }
                }
                .rotationEffect(.degrees(180))
            }
            .onTapGesture {
                #if os(iOS)
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                #endif
            }
            .scrollIndicators(.never)
            .rotationEffect(.degrees(180))
            ChatInputTextField(chatViewModel: viewModel)
        }
    }
}

#Preview {
    ChatView(modelContext: ModelContext(try! ModelContainer(for: Chat.self)), chat: Chat(title: ""))
        .modelContainer(for: Chat.self, inMemory: true)
}
