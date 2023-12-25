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
    private let errorMessageId: UUID = UUID()
    
    init(modelContext: ModelContext, chat: Chat) {
        self._viewModel = State(initialValue: ChatViewModel(modelContext: modelContext, chat: chat))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { proxy in
                    List {
                        ForEach(viewModel.sortMessages()) { message in
                            ForEach(message.contents) { content in
                                Chatbubble(author: message.author, messageType: content.type, value: content.value)
                                    .id(message.id)
                                    .listRowSeparator(.hidden)
                                    .contextMenu {
                                        contextMenuButtons(message: message, content: content)
                                    }
                            }
                        }
                        if !viewModel.errorMessage.isEmpty {
                            Chatbubble(author: .Error, messageType: .Text, value: viewModel.errorMessage)
                                .id(errorMessageId)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .onChange(of: viewModel.sortMessages().last?.contents.last?.value) { oldValue, newValue in
                        let messages = viewModel.sortMessages()
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                    .onChange(of: viewModel.errorMessage, { oldValue, newValue in
                        if !newValue.isEmpty {
                            proxy.scrollTo(errorMessageId)
                        }
                    })
                    .onAppear() {
                        let messages = viewModel.sortMessages()
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
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
    
    @ViewBuilder private func contextMenuButtons(message: MyMessage, content: MyContent) -> some View {
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

#Preview {
    ChatView(modelContext: ModelContext(try! ModelContainer(for: Chat.self)), chat: Chat(title: ""))
        .modelContainer(for: Chat.self, inMemory: true)
}
