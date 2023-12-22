//
//  ChatListView.swift
//  GPTSwift
//
//  Created by Elvis on 11/12/2023.
//

import SwiftUI
import SwiftData

struct ChatListView: View {
    @State private var count = 1
    @Environment(\.modelContext) private var modelContext
    private var fetchDescriptor = FetchDescriptor<Chat>(sortBy: [SortDescriptor(\.title)])
    @Query private var chats: [Chat]
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(chats) { chat in
                    NavigationLink {
                        ChatView(modelContext: modelContext, chat: chat)
                    } label: {
                        Text(chat.title)
                    }
                    
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        removeAllChats()
                    } label: {
                        Label("Remove", systemImage: "minus")
                    }
                }
                #elseif os(macOS)
                ToolbarItem {
                    createNewChat()
                }
                ToolbarItem {
                    Button {
                        removeAllChats()
                    } label: {
                        Label("Remove", systemImage: "minus")
                    }
                }
                #endif
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    @ViewBuilder private func createNewChat() -> some View {
        NavigationLink {
            NewChatView()
        } label: {
            Label("Add Item", systemImage: "plus")
        }

    }
    
    private func removeAllChats() {
        do {
            try modelContext.delete(model: Chat.self)
        } catch {
            print(error)
        }
        
    }
}

#Preview {
    ChatListView()
}
