//
//  NewChatView.swift
//  GPTSwift
//
//  Created by Elvis on 21/12/2023.
//

import SwiftUI
import OpenAI

struct NewChatView: View {
    @State private var openAIModels: [ModelResult] = []
    @State private var newChat: Chat = Chat(title: "")
    private let openAI = OpenAI(apiToken: KeychainService.getKey())
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        Form {
            LabeledContent("Chat Title") {
                TextField("", text: $newChat.title)
            }  
            LabeledContent("Prompt") {
                TextEditor(text: $newChat.prompt)
                    .frame(height: 150)
                    .font(.title3)
            }
            Picker(selection: $newChat.model, label: Text("GPT Version")) {
                ForEach(openAIModels) { model in
                    Text(model.id)
                        .tag(Optional(model.id))
                }
            }
            #if os(macOS)
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                Spacer()
                Button {
                    createNewChat()
                } label: {
                    Text("Create")
                }
            }
            #endif
        }
        #if os(macOS)
        .padding()
        #elseif os(iOS)
        .toolbar {
            ToolbarItem {
                Button {
                    createNewChat()
                } label: {
                    Text("Create")
                }
            }
        }
        #endif
        .onAppear() {
            fetchAvailableModels()
        }
    }
    
    private func fetchAvailableModels() {
        Task {
            let result = try? await openAI.models()
            openAIModels = result?.data.sorted(by: { $0.id < $1.id }) ?? []
            openAIModels = openAIModels.filter{ $0.id.contains("gpt") }
            if !openAIModels.isEmpty {
                newChat.model = Optional(openAIModels.first!.id)
            }
        }
    }
    
    private func createNewChat() {
        guard newChat.model != nil else {
            return
        }
        modelContext.insert(newChat)
        dismiss()
    }
}

#Preview {
    NewChatView()
}
