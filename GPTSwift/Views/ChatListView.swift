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
                    Button {
                        let newChat = Chat(title: "\(count)")
                        modelContext.insert(newChat)
                        count += 1
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        do {
                            try modelContext.delete(model: Chat.self)
                        } catch {
                            print(error)
                        }
                    } label: {
                        Label("Remove", systemImage: "minus")
                    }
                }
#endif
                ToolbarItem {
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
}

#Preview {
    ChatListView()
}
