//
//  GPTSwiftApp.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts
import SyntaxHighlightingMarkdownUI
#if os(macOS)
import Sparkle
#endif

@main
struct GPTSwiftApp: App {
    private var service = SwiftDataService()

#if os(iOS)
    init() {
        // Setup SyntaxHighlightingMarkdownUI
        DispatchQueue.global().async {
            _ = SyntaxHighlightingMarkdownUI.shared
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContext(service.sharedModelContext)
    }
#elseif os(macOS)
    private let updaterController: SPUStandardUpdaterController
    @StateObject private var appState = AppState()
    
    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        // Setup SyntaxHighlightingMarkdownUI
        DispatchQueue.global().async {
            _ = SyntaxHighlightingMarkdownUI.shared
        }
    }
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .floatingPanel(isPresented: $appState.toggleFloatWindow) {
                    FloatingChatView()
                        .modelContext(service.sharedModelContext)
                        .environmentObject(appState)
                }
        }
        .modelContext(service.sharedModelContext)
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
        }
        Settings {
            UserSettingView()
        }
    }
#endif
}

#if os(macOS)
@MainActor
final class AppState: ObservableObject {
    @Published var toggleFloatWindow: Bool = false
    
    init() {
        KeyboardShortcuts.onKeyDown(for: .toogleFloatWindow) {
            self.toggleFloatWindow.toggle()
        }
    }
}
#endif
