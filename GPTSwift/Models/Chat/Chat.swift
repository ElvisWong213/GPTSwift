//
//  Chat.swift
//  GPTSwift
//
//  Created by Elvis on 12/12/2023.
//

import Foundation
import SwiftData

@Model
class Chat: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    
    @Relationship(deleteRule: .cascade, inverse: \MyMessage.chat)
    var messages: [MyMessage] = []
    
    init(id: UUID = UUID(), title: String, messages: [MyMessage] = []) {
        self.id = id
        self.title = title
        self.messages = messages
    }
    
    func fetchMessages() -> [MyMessage] {
        let fetchDescriptor = FetchDescriptor(predicate: #Predicate<MyMessage>{ $0.chat == self })
        do {
            guard let result = try modelContext?.fetch(fetchDescriptor) else {
                return []
            }
            return result
        } catch {
            print(error)
        }
        return []
    }
    
    // Codable
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case messages
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.messages = try container.decode([MyMessage].self, forKey: .messages)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(messages, forKey: .messages)
    }
}
