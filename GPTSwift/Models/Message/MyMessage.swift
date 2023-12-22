//
//  MyMessage.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import Foundation
import OpenAI
import SwiftData

@Model
class MyMessage: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    let author: Author
    let timestamp: Date = Date.now
    
    @Relationship(deleteRule: .cascade, inverse: \MyContent.message)
    var contents: [MyContent] = []
    
    var chat: Chat?

    init(id: UUID = UUID(), author: Author, contents: [MyContent], chat: Chat? = nil, timestamp: Date = Date.now) {
        self.id = id
        self.author = author
        self.contents = contents
        self.chat = chat
        self.timestamp = timestamp
    }
    
    func convertToMessage() -> Message {
        return Message(role: author.toRole, content: .object(contents.map{ $0.convertToChatContent() }))
    }
    
    func fetchContent() -> [MyContent] {
        let fetchDescriptor = FetchDescriptor(predicate: #Predicate<MyContent>{ $0.message == self })
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
        case author
        case content
        case chat
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.author = try container.decode(Author.self, forKey: .author)
        self.contents = try container.decode([MyContent].self, forKey: .content)
        self.chat = try container.decode(Chat.self, forKey: .chat)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(author, forKey: .author)
        try container.encode(contents, forKey: .content)
        try container.encode(chat, forKey: .chat)
    }
}

extension MyMessage: Equatable {
    static func == (lhs: MyMessage, rhs: MyMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

extension MyMessage {
    static var MOCK: [MyMessage] = [
        .init(author: .User, contents: [MyContent(type: .Text, value: "Hic ut magnam cumque placeat exercitationem aut id itaque. Laborum culpa doloremque doloribus ducimus numquam corporis tempore quis. Temporibus laboriosam ut illo facilis. Corporis fugit a esse error sit. Illum animi ducimus vero vero reiciendis. Quaerat nemo quibusdam sint.")]),
        .init(author: .GPT, contents: [MyContent(type: .Text, value: "Distinctio suscipit dignissimos maiores officia ullam. Dicta facilis molestias. Quo architecto architecto ab aspernatur ab ex eum ipsam. Accusamus neque officia laudantium. Id ad porro blanditiis laboriosam ea hic.Officia eaque perferendis necessitatibus tempore porro. Consequuntur consectetur molestias reprehenderit eum ea corrupti quam incidunt suscipit. Asperiores autem ducimus exercitationem odio. Dolorum corrupti delectus consequatur magni tempora inventore.Voluptatum fugit ipsa cum rem unde veniam suscipit aperiam suscipit. Fugiat tenetur hic repudiandae. Accusamus ab placeat culpa.")]),
        .init(author: .User, contents: [MyContent(type: .Text, value: "Quam sequi dolore assumenda inventore. Debitis aut ullam est velit numquam nobis provident. In esse tempora eligendi ullam aperiam sunt esse ab. Animi suscipit incidunt nisi corrupti.")])
    ]
}