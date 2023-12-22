//
//  Chat.swift
//  GPTSwift
//
//  Created by Elvis on 12/12/2023.
//

import Foundation
import SwiftData
import OpenAI

@Model
class Chat: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var model: Model?
    var prompt: String
    
    @Relationship(deleteRule: .cascade, inverse: \MyMessage.chat)
    var messages: [MyMessage] = []
    
    init(id: UUID = UUID(), title: String, model: Model? = nil, prompt: String = "", messages: [MyMessage] = []) {
        self.id = id
        self.title = title
        self.model = model
        self.prompt = prompt
        self.messages = messages
    }
    
    func convertToChatQuery() -> ChatQuery {
        let promptMessage = MyMessage(author: .System, contents: [MyContent(type: .Text, value: prompt)], chat: self)
        var messages = self.messages.sorted(by: { $0.timestamp < $1.timestamp } ).map{ $0.convertToMessage() }
        messages.insert(promptMessage.convertToMessage(), at: 0)
        return ChatQuery(model: self.model!, messages: messages)
    }
    
    // Codable
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case messages
        case model
        case prompt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.messages = try container.decode([MyMessage].self, forKey: .messages)
        self.model = try container.decode(Model.self, forKey: .model)
        self.prompt = try container.decode(String.self, forKey: .prompt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(messages, forKey: .messages)
        try container.encode(model, forKey: .model)
        try container.encode(prompt, forKey: .prompt)
    }
}
