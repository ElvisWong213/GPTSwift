//
//  ChatListView.swift
//  GPTSwift
//
//  Created by Elvis on 11/12/2023.
//

import SwiftUI
import SwiftData
import OpenAI

struct ChatListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("chatsPrompt") var chatsPrompt: String = ""
    @AppStorage("chatsModel") var chatsModel: Model?
    @AppStorage("chatsMaxToken") var chatsMaxToken: Int?
    
    static var descriptor: FetchDescriptor<Chat> {
        var descriptor = FetchDescriptor<Chat>(sortBy: [SortDescriptor<Chat>(\.updateDate, order: .reverse)])
        let floatingChatTitle = "New Floating Chat"
        descriptor.predicate = #Predicate<Chat> { $0.title != floatingChatTitle }
        return descriptor
    }
    
    @Query(descriptor, animation: .easeIn) private var chats: [Chat]
    @State private var selectedChat: Chat?
    
    var body: some View {
        NavigationSplitView {
            List(chats, id: \.self, selection: $selectedChat) { chat in
                HStack {
                    Text(chat.title.isEmpty ? "New Chat" : chat.title)
                    Spacer()
                    Text(chat.getModelString())
                        .font(.footnote)
                        .padding(3)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 0.5)
                        }
                }
                .contextMenu {
                    contextMenuButtons(chat: chat)
                }
                .swipeActions() {
                    Button {
                        removeChat(chat: chat)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
                
            }
            .navigationTitle("Chats")
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    createNewChat()
                }
#elseif os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    createNewChat()
                }
#endif
            }
        } detail: {
            if let selectedChat = selectedChat {
                NavigationStack {
                    ChatView(modelContext: modelContext, chatId: selectedChat.id)
                        .id(selectedChat.id)
                }
                .navigationTitle(selectedChat.title.isEmpty ? "New Chat" : selectedChat.title)
#if os(macOS)
                .navigationSubtitle(selectedChat.getModelString())
#elseif os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Text(selectedChat.getModelString())
                            .font(.footnote)
                            .padding(3)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray, lineWidth: 0.5)
                            }
                    }
                }
#endif
            } else {
                Text("Select a chat")
            }
        }
    }
    
    @ViewBuilder private func createNewChat() -> some View {
        Button {
            createNewChat()
        } label: {
            Label("Add Item", systemImage: "plus")
        }
        .keyboardShortcut("n", modifiers: .command)
    }
    
    private func createNewChat() {
        let title = ""
        var maxToken = chatsMaxToken
        if chatsModel == .gpt4_vision_preview && maxToken == nil {
            maxToken = 4096
        }
        let newChat = Chat(title: title, model: chatsModel, prompt: chatsPrompt, maxToken: maxToken)
        modelContext.insert(newChat)
        try? modelContext.save()
        selectedChat = newChat
    }
    
    private func removeChat(chat: Chat) {
        modelContext.delete(chat)
        try? modelContext.save()
    }
    
    
    @ViewBuilder private func contextMenuButtons(chat: Chat) -> some View {
        Button(role: .destructive) {
            removeChat(chat: chat)
            selectedChat = nil
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

#if DEBUG
#Preview {
    ChatListView()
        .modelContainer(SwiftDataService.previewData)
}
#endif
