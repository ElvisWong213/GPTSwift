//
//  UserSettingView.swift
//  GPTSwift
//
//  Created by Elvis on 11/12/2023.
//

import SwiftUI
import KeyboardShortcuts
import OpenAI

struct UserSettingView: View {
    @State private var apiKey: String = ""
    
    @State private var openAIService = OpenAIService.shared
    @State private var isRemoveKey: Bool = false
    
    @AppStorage("markdownToggle") var markdownToggle: Bool = true
        
    // Chats Setting
    @AppStorage("chatsPrompt") var chatsPrompt: String = ""
    @AppStorage("chatsModel") var chatsModel: Model?
    @AppStorage("chatsMaxToken") var chatsMaxToken: Int?
    
    // Floating Window Setting
    @AppStorage ("floatingWindowPrompt") var floatingWindowPrompt: String = ""
    @AppStorage ("floatingWindowModel") var floatingWindowModel: Model?
    
    var body: some View {
        VStack {
#if os(iOS)
            iosSettingView()
#elseif os(macOS)
            macOSSettingView()
#endif
        }
        .onAppear() {
            apiKey = KeychainService.getKey()
            setupModels()
        }
    }
    
    @ViewBuilder private func enterApiKeyView() -> some View {
        LabeledContent {
            TextField("", text: $apiKey)
                .multilineTextAlignment(.trailing)
                .onSubmit {
                    KeychainService.setKey(key: apiKey)
                }
                .onChange(of: apiKey) {
                    KeychainService.setKey(key: apiKey)
                }
                .submitLabel(.done)
        } label: {
            Text("API Key")
        }
        Button {
            isRemoveKey = true
        } label: {
            Text("Delete Key")
        }
        .confirmationDialog("Delete API Key?", isPresented: $isRemoveKey) {
            Button(role: .destructive) {
                if KeychainService.deleteKey() {
                    apiKey = ""
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cencel")
            }
        }
        Toggle(isOn: $markdownToggle) {
            Text("Show Markdown")
        }
#if os(macOS)
        .toggleStyle(.checkbox)
#endif
    }
    
    @ViewBuilder private func chatsSettingView() -> some View {
        LabeledContent("Prompt") {
            TextEditor(text: $chatsPrompt)
                .frame(height: 150)
                .font(.title3)
        }
        LabeledContent("Max Token") {
            TextField("", value: $chatsMaxToken, format: .number)
                .submitLabel(.done)
        }
        Picker(selection: $chatsModel, label: Text("GPT Version")) {
            ForEach(openAIService.availableModels) { model in
                Text(model.id)
                    .tag(Optional(model.id))
            }
        }
    }
    
    private func setupModels() {
        if floatingWindowModel == nil {
            floatingWindowModel = openAIService.availableModels.first?.id
        }
        if chatsModel == nil {
            chatsModel = openAIService.availableModels.first?.id
        }
    }
}


// iOS
extension UserSettingView {
#if os(iOS)
    @ViewBuilder private func iosSettingView() -> some View {
        NavigationStack {
            Form {
                Section("API Key") {
                    // API Key entery
                    enterApiKeyView()
                }
                Section("Chat Setting") {
                    chatsSettingView()
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Setting")
        }
    }
#endif
}

// MacOS
extension UserSettingView {
#if os(macOS)
    @ViewBuilder private func macOSSettingView() -> some View {
        TabView {
            // API Key entery
            Form {
                enterApiKeyView()
            }
                .tabItem { Label("General", systemImage: "gearshape") }
            Form {
                chatsSettingView()
            }
                .tabItem { Label("Chats", systemImage: "message") }
            // Floating Window
            floatingWindowSetting()
                .tabItem { Label("Float Window", systemImage: "macwindow.on.rectangle") }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
    
    @ViewBuilder private func floatingWindowSetting() -> some View {
        Form {
            // Hotkey
            KeyboardShortcuts.Recorder("Toggle Floating Window", name: .toogleFloatWindow)
            
            // Floating Window Default
            LabeledContent("Prompt") {
                TextEditor(text: $floatingWindowPrompt)
                    .frame(height: 150)
                    .font(.title3)
            }
            Picker(selection: $floatingWindowModel, label: Text("GPT Version")) {
                ForEach(openAIService.availableModels) { model in
                    Text(model.id)
                        .tag(Optional(model.id))
                }
            }
        }
    }
#endif
}

enum SettringViewEnum {
    case apiKey
}

#if DEBUG
#Preview {
    UserSettingView()
}
#endif
