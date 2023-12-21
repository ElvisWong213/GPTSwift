//
//  APIDataHelper.swift
//  GPTSwift
//
//  Created by Elvis on 19/12/2023.
//

import Foundation
import OpenAI

class APIDataHelper {
    static func convertToChatContent(content: MyContent) -> ChatContent {
        return ChatContent(type: content.type.chatContentType, value: content.value)
    }
    
    static func convertToMessage(message: MyMessage) -> Message {
        return Message(role: message.author.toRole, content: .object(message.contents.map{ $0.convertToChatContent() }))
    }
}
