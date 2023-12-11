//
//  MyContent.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import Foundation
import OpenAI

struct MyContent: Identifiable {
    let id = UUID()
    let type: MessageType
    var value: String
    
    func convertToChatContent() -> ChatContent {
        return .init(type: type.chatContentType, value: value)
    }
}
