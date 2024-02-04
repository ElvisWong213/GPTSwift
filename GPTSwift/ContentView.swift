//
//  ContentView.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    var body: some View {
#if os(iOS)
        TabView {
            ChatListView()
                .tabItem {
                    Label("Chats", systemImage: "message")
                }
            UserSettingView()
                .tabItem {
                    Label("Setting", systemImage: "gearshape")
                }
        }
#else
        ChatListView()
#endif
    }
}

#if DEBUG
#Preview {
    ContentView()
}
#endif
