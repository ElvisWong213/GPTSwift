//
//  UserSettingView.swift
//  GPTSwift
//
//  Created by Elvis on 11/12/2023.
//

import SwiftUI

struct UserSettingView: View {
    @State private var apiKey: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                enterApiKeyView()
                Button {
                    if KeychainService.deleteKey() {
                        apiKey = ""
                    }
                } label: {
                    Text("Delete Key")
                }
            }
            .navigationTitle("Setting")
        }
        #if os(macOS)
        .padding()
        .frame(width: 375, height: 150)
        #endif
        .onAppear() {
            apiKey = KeychainService.getKey()
        }
    }
    
    @ViewBuilder private func enterApiKeyView() -> some View {
        VStack {
            LabeledContent {
                TextField("", text: $apiKey)
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        KeychainService.setKey(key: apiKey)
                    }
                    .submitLabel(.done)
            } label: {
                Text("API Key")
            }
        }
    }
}

enum SettringViewEnum {
    case apiKey
}

#Preview {
    UserSettingView()
}
