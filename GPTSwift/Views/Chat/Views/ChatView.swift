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
    private var latestMessageString: String? {
        get {
            viewModel.getLatestMessage()?.contents.last?.value
        }
    }
    
    init(modelContext: ModelContext, chat: Chat, isTempMessage: Bool = false) {
        let viewModel = ChatViewModel(modelContext: modelContext, chat: chat, isTempMessage: isTempMessage)
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    allMessages()
                    errorMessage()
                }
                .onChange(of: viewModel.errorMessage, { oldValue, newValue in
                    if !newValue.isEmpty {
                        proxy.scrollTo(errorMessageId)
                    }
                })
                .onChange(of: latestMessageString) { oldValue, newValue in
                    proxy.scrollTo(viewModel.getLatestMessage()?.id, anchor: .bottom)
                }
                .onAppear() {
                    proxy.scrollTo(viewModel.getLatestMessage()?.id, anchor: .bottom)
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
#if os(iOS)
        .toolbar(.hidden, for: .tabBar)
#endif
    }
    
    @ViewBuilder private func contextMenuButtons(message: MyMessage, content: MyContent) -> some View {
        Button {
#if os(iOS)
            UIPasteboard.general.setValue(content.value, forPasteboardType: UTType.plainText.identifier)
#elseif os(macOS)
            NSPasteboard.general.setString(content.value, forType: .string)
#endif
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }
        Button(role: .destructive) {
            viewModel.removeMessage(message: message)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    @ViewBuilder private func allMessages() -> some View {
        ForEach(viewModel.sortMessages()) { message in
            ForEach(message.contents) { content in
                Chatbubble(author: message.author, messageType: content.type, value: content.value)
                    .id(message.id)
                    .contextMenu {
                        contextMenuButtons(message: message, content: content)
                    }
            }
        }
    }
    
    @ViewBuilder private func errorMessage() -> some View {
        if !viewModel.errorMessage.isEmpty {
            Chatbubble(author: .Error, messageType: .Text, value: viewModel.errorMessage)
                .id(errorMessageId)
                .listRowSeparator(.hidden)
        }
    }
}

#Preview {
    ChatView(modelContext: ModelContext(try! ModelContainer(for: Chat.self)), chat: Chat(title: ""))
        .modelContainer(for: Chat.self, inMemory: true)
}
