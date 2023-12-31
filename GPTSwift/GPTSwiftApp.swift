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
    //    var sharedModelContainer: ModelContainer = {
    //        let schema = Schema([
    //            Chat.self,
    //        ])
    //        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    //
    //        do {
    //            return try ModelContainer(for: schema, configurations: [modelConfiguration])
    //        } catch {
    //            fatalError("Could not create ModelContainer: \(error)")
    //        }
    //    }()
#if os(macOS)
    @StateObject private var appState = AppState()
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(macOS)
                .floatingPanel(isPresented: $appState.toggleFloatWindow) {
                    FloatingChatView()
                        .modelContainer(for: [Chat.self], isAutosaveEnabled: false)
                }
#endif
        }
        .modelContainer(for: [Chat.self], isAutosaveEnabled: false)
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
    
    init() {
        KeyboardShortcuts.onKeyDown(for: .toogleFloatWindow) {
            self.toggleFloatWindow.toggle()
        }
    }
}
#endif
