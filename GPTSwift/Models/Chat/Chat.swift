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
    
    func getModelString() -> String {
        guard let model = self.model else {
            return ""
        }
        switch model {
        case .gpt4, .gpt4_32k, .gpt4_0613, .gpt4_1106_preview:
            return "GPT4"
        case .gpt4_vision_preview:
            return "GPT4 Vision"
        case .gpt3_5Turbo, .gpt3_5Turbo_16k, .gpt3_5Turbo_1106, .gpt3_5Turbo_16k_0613:
            return "GPT3.5"
        default:
            return ""
        }
    }
    
    #if DEBUG
    static let MOCK: Chat = Chat(title: "Test Data Chat", model: .gpt3_5Turbo, messages: [
        MyMessage(id: UUID(), author: .User, contents: [
            MyContent(type: .Text, value: "Dolorum pariatur exercitationem ipsum eum nulla. Optio fugiat nostrum nesciunt eius pariatur quaerat reiciendis architecto repellat.")
        ]),
        MyMessage(id: UUID(), author: .GPT, contents: [
            MyContent(type: .Text, value: "Quod cupiditate voluptas. Veniam tenetur nam. A explicabo expedita a laudantium provident exercitationem numquam commodi repellat. Ratione ad aut laboriosam earum eaque. Rem praesentium occaecati dolore adipisci voluptatem nesciunt. Voluptas quidem beatae corrupti.")
        ]),
    ])
    #endif
}
