//
//  GPTSwiftApp.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI
import SwiftData

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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Chat.self], isAutosaveEnabled: false)
        #if os(macOS)
        Settings {
            UserSettingView()
        }
        #endif
    }
}
