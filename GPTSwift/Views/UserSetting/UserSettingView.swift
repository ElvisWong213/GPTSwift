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
    
    @State private var openAIModels: [ModelResult] = []
    @AppStorage ("defaultPrompt") var prompt: String = ""
    @AppStorage ("defaultModel") var model: Model?
    
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
        }
    }
    
    @ViewBuilder private func enterApiKeyView() -> some View {
        Form {
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
                if KeychainService.deleteKey() {
                    apiKey = ""
                }
            } label: {
                Text("Delete Key")
            }
        }
    }
}


// iOS
extension UserSettingView {
#if os(iOS)
    @ViewBuilder private func iosSettingView() -> some View {
        NavigationStack {
            // API Key entery
            enterApiKeyView()
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
            enterApiKeyView()
                .tabItem { Label("General", systemImage: "gearshape") }
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
                TextEditor(text: $prompt)
                    .frame(height: 150)
                    .font(.title3)
            }
            Picker(selection: $model, label: Text("GPT Version")) {
                ForEach(openAIModels) { model in
                    Text(model.id)
                        .tag(Optional(model.id))
                }
            }
        }
        .onAppear() {
            fetchAllModels()
        }
    }
    
    private func fetchAllModels() {
        Task {
            openAIModels = await OpenAIService.fetchAvailableModels()
            if !openAIModels.isEmpty && model == nil {
                model = Optional(openAIModels.first!.id)
            }
        }
    }
#endif
}

enum SettringViewEnum {
    case apiKey
}

#Preview {
    UserSettingView()
}
