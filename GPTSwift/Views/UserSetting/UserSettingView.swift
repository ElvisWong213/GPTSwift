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
        .onAppear() {
            apiKey = KeychainService.getKey()
        }
    }
    
    @ViewBuilder private func enterApiKeyView() -> some View {
        VStack {
            LabeledContent {
                TextField("", text: $apiKey)
                    .onSubmit {
                        KeychainService.setKey(key: apiKey)
                    }
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
