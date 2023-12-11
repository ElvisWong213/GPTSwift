//
//  Author.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import Foundation
import OpenAI

enum Author {
    case User, GPT
    
    var isUser: Bool {
        switch self {
        case .User:
            return true
        case .GPT:
            return false
        }
    }
    
    var toRole: Message.Role {
        switch self {
        case .User:
            return .user
        case .GPT:
            return .assistant
        }
    }
}
