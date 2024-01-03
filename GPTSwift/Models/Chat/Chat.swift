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
    var maxToken: Int?
    var updateDate: Date = Date.now
    
    @Relationship(deleteRule: .cascade, inverse: \MyMessage.chat)
    var messages: [MyMessage] = []
    
    init(id: UUID = UUID(), title: String, model: Model? = nil, prompt: String = "", messages: [MyMessage] = [], maxToken: Int? = nil, updateDate: Date = Date.now) {
        self.id = id
        self.title = title
        self.model = model
        self.prompt = prompt
        self.messages = messages
        self.maxToken = maxToken
        self.updateDate = updateDate
    }
    
    // Codable
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case messages
        case model
        case prompt
        case maxToken
        case updateDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.messages = try container.decode([MyMessage].self, forKey: .messages)
        self.model = try container.decode(Model.self, forKey: .model)
        self.prompt = try container.decode(String.self, forKey: .prompt)
        self.maxToken = try container.decode(Int.self, forKey: .maxToken)
        self.updateDate = try container.decode(Date.self, forKey: .updateDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(messages, forKey: .messages)
        try container.encode(model, forKey: .model)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(maxToken, forKey: .maxToken)
        try container.encode(updateDate, forKey: .updateDate)
    }
}
