//
//  NewChatView.swift
//  GPTSwift
//
//  Created by Elvis on 21/12/2023.
//

import SwiftUI
import OpenAI

struct NewChatView: View {
    @Binding var selectedChat: Chat?
    
    @State private var openAIModels: [ModelResult] = []
    @State private var title: String = ""
    @State private var prompt: String = ""
    @State private var model: Model?
    @State private var maxToken: Int? = nil
    @State var editChat: Chat? = nil
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            LabeledContent("Chat Title") {
                TextField("", text: $title)
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Prompt") {
                TextEditor(text: $prompt)
                    .frame(height: 150)
                    .font(.title3)
            }
            LabeledContent("Max Token") {
                TextField("", value: $maxToken, format: .number)
#if os(iOS)
                    .keyboardType(.numberPad)
#endif
                    .multilineTextAlignment(.trailing)
            }
            Picker(selection: $model, label: Text("GPT Version")) {
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
                    if editChat != nil {
                        updateChat()
                    } else {
                        createNewChat()
                    }
                } label: {
                    Text(editChat != nil ? "Save" : "Create")
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
                    if editChat != nil {
                        updateChat()
                    } else {
                        createNewChat()
                    }
                } label: {
                    Text(editChat != nil ? "Save" : "Create")
                }
            }
        }
#endif
        .toolbarTitleDisplayMode(.inline)
        .navigationTitle(editChat != nil ? "Edit Chat" : "Create New Chat")
        .onAppear() {
            setUpEditChat()
            fetchAvailableModels()
        }
    }
    
    private func fetchAvailableModels() {
        Task {
            openAIModels = await OpenAIService.fetchAvailableModels()
            if !openAIModels.isEmpty && model == nil {
                model = Optional(openAIModels.first!.id)
            }
        }
    }
    
    private func setUpEditChat() {
        guard let editChat else {
            return
        }
        title = editChat.title
        model = editChat.model
        prompt = editChat.prompt
        maxToken = editChat.maxToken
    }
    
    private func createNewChat() {
        guard model != nil else {
            return
        }
        if title.isEmpty {
            title = "New Chat"
        }
        if model == .gpt4_vision_preview && maxToken == nil {
            maxToken = 4096
        }
        let newChat = Chat(title: title, model: model, prompt: prompt, maxToken: maxToken)
        modelContext.insert(newChat)
        try? modelContext.save()
        selectedChat = newChat
    }
    
    func updateChat() {
        guard model != nil else {
            return
        }
        if title.isEmpty {
            title = "New Chat"
        }
        if model == .gpt4_vision_preview && maxToken == nil {
            maxToken = 4096
        }
        editChat?.title = title
        editChat?.model = model
        editChat?.prompt = prompt
        editChat?.maxToken = maxToken
        try? modelContext.save()
        dismiss()
    }
    
}

#Preview {
    NewChatView(selectedChat: .constant(Chat(title: "")))
        .modelContainer(for: [Chat.self])
}
