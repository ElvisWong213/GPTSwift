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
    @Query private var chats: [Chat]
    @State private var selectedChat: Chat?
    
    var body: some View {
        NavigationSplitView {
            List(chats, selection: $selectedChat) { chat in
                NavigationLink(chat.title, value: chat)
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
            if selectedChat != nil {
                ChatView(modelContext: modelContext, chat: selectedChat!)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(selectedChat!.title)
            }
        }
    }
    
    @ViewBuilder private func createNewChat() -> some View {
        NavigationLink {
            NewChatView(selectedChat: $selectedChat)
        } label: {
            Label("Add Item", systemImage: "plus")
        }

    }
    
    private func removeChat(chat: Chat) {
        modelContext.delete(chat)
        try? modelContext.save()
    }
}

#Preview {
    ChatListView()
        .modelContainer(for: [Chat.self])
}
