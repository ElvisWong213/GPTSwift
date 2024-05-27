//
//  FloatingChatView.swift
//  GPTSwift
//
//  Created by Elvis on 30/12/2023.
//

#if os(macOS)
import SwiftUI
import OpenAI

struct FloatingChatView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @State private var chat: Chat?
    
    @AppStorage ("floatingWindowPrompt") var prompt: String = ""
    @AppStorage ("floatingWindowModel") var model: Model?

    var body: some View {
        VStack {
            ZStack {
                title()
                HStack {
                    Spacer()
                    Button {
                        clearChat()
                    } label: {
                        Text("Clear")
                    }
//                        Button {
//                            saveChat()
//                        } label: {
//                            Text("Save")
//                        }
                }
            }
            if let chat = chat {
                ChatView(modelContext: modelContext, chatId: chat.id, isTempMessage: true)
            }
        }
        .padding()
        .frame(width: 700, height: 512)
        .background(VisualEffect(material: .sidebar, blendingMode: .behindWindow))
        .onAppear() {
            createNewChat()
        }
        .onChange(of: prompt) {
            chat?.prompt = prompt
        }
        .onChange(of: model) {
            chat?.model = model
        }
    }
    
    @ViewBuilder func title() -> some View {
        HStack {
            Text(chat?.title ?? "")
                .font(.title3)
                .bold()
            Text(chat?.getModelString() ?? "")
                .font(.footnote)
                .padding(3)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray, lineWidth: 0.5)
                }
        }
    }
    
    private func createNewChat() {
        if model == nil {
            model = .gpt3_5Turbo
        }
        let newChat = Chat(title: "New Floating Chat", model: model, prompt: prompt)
        chat = newChat
        modelContext.insert(newChat)
    }
    
    private func clearChat() {
        chat?.messages = []
    }
    
    private func saveChat() {
        try? modelContext.save()
    }
}

#if DEBUG
#Preview {
    FloatingChatView()
        .environmentObject(AppState())
}
#endif
#endif
