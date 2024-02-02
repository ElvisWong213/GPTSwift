//
//  EditChatView.swift
//  GPTSwift
//
//  Created by Elvis on 21/12/2023.
//

import SwiftUI
import OpenAI

struct EditChatView: View {
    @State private var openAIService = OpenAIService.shared
    @State var editChat: Chat
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            LabeledContent("Chat Title") {
                TextField("", text: $editChat.title)
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Prompt") {
                TextEditor(text: $editChat.prompt)
                    .frame(height: 150)
                    .font(.title3)
            }
            LabeledContent("Max Token") {
                TextField("", value: $editChat.maxToken, format: .number)
#if os(iOS)
                    .keyboardType(.numberPad)
#endif
                    .multilineTextAlignment(.trailing)
            }
            Picker(selection: $editChat.model, label: Text("GPT Version")) {
                ForEach(openAIService.availableModels) { model in
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
                    updateChat()
                } label: {
                    Text("Save")
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
                    updateChat()
                } label: {
                    Text("Save")
                }
            }
        }
#endif
        .toolbarTitleDisplayMode(.inline)
        .navigationTitle("Edit Chat")
    }
    
    func updateChat() {
        if editChat.title.isEmpty {
            editChat.title = "New Chat"
        }
        if editChat.model == .gpt4_vision_preview && editChat.maxToken == nil {
            editChat.maxToken = 4096
        }
        try? modelContext.save()
        dismiss()
    }
    
}

#Preview {
    EditChatView(editChat: Chat(title: ""))
        .modelContainer(for: [Chat.self])
}
