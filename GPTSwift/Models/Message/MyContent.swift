//
//  MyContent.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import Foundation
import OpenAI
import SwiftData

@Model
class MyContent: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    let type: MessageType
    var value: String
    
    var message: MyMessage?
    
    init(id: UUID = UUID(), type: MessageType, value: String, message: MyMessage? = nil) {
        self.id = id
        self.type = type
        self.value = value
        self.message = message
    }
    
    func convertToChatContent() -> ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content {
        switch type {
        case .Text:
            return .string(value)
        case .Image:
            return .vision([.chatCompletionContentPartImageParam(.init(imageUrl: .init(url: "data:image/jpeg;base64,\(value)", detail: .auto)))])
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case value
        case message
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(MessageType.self, forKey: .type)
        self.value = try container.decode(String.self, forKey: .value)
        self.message = try container.decode(MyMessage.self, forKey: .message)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(value, forKey: .value)
        try container.encode(message, forKey: .message)
    }
}
