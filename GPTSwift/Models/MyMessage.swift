//
//  MyMessage.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import Foundation
import OpenAI

struct MyMessage: Identifiable {
    let id = UUID()
    let author: Author
    var content: [MyContent]
    
    func convertToMessage() -> Message {
        return .init(role: author.toRole, content: .object(content.map{ $0.convertToChatContent() }))
    }
}

extension MyMessage {
    static var MOCK: [MyMessage] = [
        .init(author: .User, content: [MyContent(type: .Text, value: "Hic ut magnam cumque placeat exercitationem aut id itaque. Laborum culpa doloremque doloribus ducimus numquam corporis tempore quis. Temporibus laboriosam ut illo facilis. Corporis fugit a esse error sit. Illum animi ducimus vero vero reiciendis. Quaerat nemo quibusdam sint.")]),
        .init(author: .GPT, content: [MyContent(type: .Text, value: "Distinctio suscipit dignissimos maiores officia ullam. Dicta facilis molestias. Quo architecto architecto ab aspernatur ab ex eum ipsam. Accusamus neque officia laudantium. Id ad porro blanditiis laboriosam ea hic.Officia eaque perferendis necessitatibus tempore porro. Consequuntur consectetur molestias reprehenderit eum ea corrupti quam incidunt suscipit. Asperiores autem ducimus exercitationem odio. Dolorum corrupti delectus consequatur magni tempora inventore.Voluptatum fugit ipsa cum rem unde veniam suscipit aperiam suscipit. Fugiat tenetur hic repudiandae. Accusamus ab placeat culpa.")]),
        .init(author: .User, content: [MyContent(type: .Text, value: "Quam sequi dolore assumenda inventore. Debitis aut ullam est velit numquam nobis provident. In esse tempora eligendi ullam aperiam sunt esse ab. Animi suscipit incidunt nisi corrupti.")])
    ]
}
