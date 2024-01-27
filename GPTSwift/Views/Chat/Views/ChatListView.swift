//
//  ChatListView.swift
//  GPTSwift
//
//  Created by Elvis on 11/12/2023.
//

import SwiftUI
import SwiftData

struct ChatListView: View {
    @Environment(\.modelContext) private var modelContext
    
    static var descriptor: FetchDescriptor<Chat> {
        var descriptor = FetchDescriptor<Chat>(sortBy: [SortDescriptor<Chat>(\.updateDate, order: .reverse)])
        descriptor.predicate = #Predicate<Chat> { !$0.title.contains("New Floating Chat") }
        return descriptor
    }
    
    @Query(descriptor, animation: .easeIn) private var chats: [Chat]
    @State private var selectedChat: Chat?
    
    var body: some View {
        NavigationSplitView {
            List(chats, id: \.self, selection: $selectedChat) { chat in
                Text(chat.title)
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
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    createNewChat()
                }
#elseif os(macOS)
                ToolbarItem {
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
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .navigationTitle(selectedChat.title)
            } else {
                Text("Select a chat")
            }
        }
    }
    
    @ViewBuilder private func createNewChat() -> some View {
        NavigationLink {
            NewChatView(selectedChat: $selectedChat)
        } label: {
            Label("Add Item", systemImage: "plus")
        }
        .keyboardShortcut("n", modifiers: .command)
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

#Preview {
    ChatListView()
        .modelContainer(for: [Chat.self])
}
