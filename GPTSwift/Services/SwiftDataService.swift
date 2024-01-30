//
//  SwiftDataService.swift
//  GPTSwift
//
//  Created by Elvis on 30/01/2024.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataService: MyServices {
    static let previewData: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Chat.self, configurations: config)
            
            for i in 1..<5 {
                let chat = Chat.MOCK
                container.mainContext.insert(chat)
            }
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
    
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
}

// MARK: - Use to fix Error: "Call to main actor-isolated initializer 'init()' in a synchronous nonisolated context"
class MyServices {}
