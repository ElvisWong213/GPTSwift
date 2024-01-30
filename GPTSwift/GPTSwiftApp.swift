//
//  GPTSwiftApp.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

@main
struct GPTSwiftApp: App {
    private var service = SwiftDataService()
#if os(macOS)
    @StateObject private var appState = AppState()
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(macOS)
                .floatingPanel(isPresented: $appState.toggleFloatWindow, isUpdatedSetting: $appState.isUpdatedSetting) {
                    FloatingChatView()
                        .modelContext(service.sharedModelContext)
                        .environmentObject(appState)
                }
#endif
        }
        .modelContext(service.sharedModelContext)
#if os(macOS)
        Settings {
            UserSettingView()
        }
#endif
    }
}

#if os(macOS)
@MainActor
final class AppState: ObservableObject {
    @Published var toggleFloatWindow: Bool = false
    @Published var isUpdatedSetting: Bool = false
    
    init() {
        KeyboardShortcuts.onKeyDown(for: .toogleFloatWindow) {
            self.toggleFloatWindow.toggle()
        }
    }
}
#endif
