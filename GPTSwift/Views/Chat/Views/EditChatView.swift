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
    @State private var title: String = ""
    @State private var prompt: String = ""
    @State private var model: Model = .gpt3_5Turbo_1106
    @State private var maxToken: Int? = nil
    @State var editChat: Chat?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if editChat != nil {
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
        }
        .onAppear() {
            setUpEditChat()
        }
    }
    
    private func setUpEditChat() {
        guard let editChat else {
            return
        }
        title = editChat.title
        model = editChat.model ?? .gpt3_5Turbo_1106
        prompt = editChat.prompt
        maxToken = editChat.maxToken
    }
    
    private func updateChat() {
        guard editChat != nil else {
            return
        }
        if title.isEmpty {
            title = ""
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

#if DEBUG
#Preview {
    EditChatView(editChat: Chat(title: ""))
        .modelContainer(for: [Chat.self])
}
#endif
