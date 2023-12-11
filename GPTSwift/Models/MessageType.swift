//
//  MessageType.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import Foundation
import OpenAI

enum MessageType {
    case Text, Image
    
    var chatContentType: ChatContent.ChatContentType {
        switch self {
        case .Text:
            return .text
        case .Image:
            return .imageUrl
        }
    }
}
