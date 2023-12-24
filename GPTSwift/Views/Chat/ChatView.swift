//
//  ChatView.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ChatView: View {
    @State private var viewModel: ChatViewModel
    
    init(modelContext: ModelContext, chat: Chat) {
        self._viewModel = State(initialValue: ChatViewModel(modelContext: modelContext, chat: chat))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.chat.messages.sorted(by: { $0.timestamp < $1.timestamp } )) { message in
                        ForEach(message.contents) { content in
                            Chatbubble(author: message.author, messageType: content.type, value: content.value)
                                .listRowSeparator(.hidden)
                                .contextMenu {
                                    Button {
                                        UIPasteboard.general.setValue(content.value, forPasteboardType: UTType.plainText.identifier)
                                    } label: {
                                        Label("Copy", systemImage: "doc.on.doc")
                                    }
                                    Button(role: .destructive) {
                                        viewModel.removeMessage(message: message)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    if !viewModel.errorMessage.isEmpty {
                        Chatbubble(author: .Error, messageType: .Text, value: viewModel.errorMessage)
                            .listRowSeparator(.hidden)
                    }
                }
                .onTapGesture {
                    #if os(iOS)
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    #endif
                }
                .scrollIndicators(.never)
                .listStyle(.plain)
                ChatInputTextField(chatViewModel: viewModel)
            }
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        NewChatView(selectedChat: .constant(nil), editChat: viewModel.chat)
                    } label: {
                        Text("Edit")
                    }
                }
            }
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

#Preview {
    ChatView(modelContext: ModelContext(try! ModelContainer(for: Chat.self)), chat: Chat(title: ""))
        .modelContainer(for: Chat.self, inMemory: true)
}
