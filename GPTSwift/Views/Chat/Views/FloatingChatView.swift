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
    @State private var isClearChat: Bool = false
    
    @AppStorage("floatingWindowPrompt") var prompt: String = ""
    @AppStorage("floatingWindowModel") var model: Model?

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
                }
            }
            if let chat = chat {
                ChatView(selectedChat: .constant(nil), modelContext: modelContext, chatId: chat.id, isTempMessage: true, clearChat: $isClearChat)
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
        self.isClearChat = true
    }
}

#if DEBUG
#Preview {
    FloatingChatView()
        .environmentObject(AppState())
}
#endif
#endif
