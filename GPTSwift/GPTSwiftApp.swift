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
    var sharedModelContext: ModelContext = {
        let schema = Schema([
            Chat.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(container)
            context.autosaveEnabled = false
            return context
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
#if os(macOS)
    @StateObject private var appState = AppState()
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(macOS)
                .floatingPanel(isPresented: $appState.toggleFloatWindow, isUpdatedSetting: $appState.isUpdatedSetting) {
                    FloatingChatView()
                        .modelContext(sharedModelContext)
                        .environmentObject(appState)
                }
#endif
        }
        .modelContext(sharedModelContext)
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
