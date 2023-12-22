//
//  Author.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import Foundation
import OpenAI

enum Author: Codable {
    case User, GPT, Error, System
    
    var isUser: Bool {
        switch self {
        case .User:
            return true
        case .GPT, .Error, .System:
            return false
        }
    }
    
    var toRole: Message.Role {
        switch self {
        case .User:
            return .user
        case .GPT:
            return .assistant
        case .Error:
            return .system
        case .System:
            return .system
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case User = "User"
        case GPT = "GPT"
        case Error = "Error"
        case System = "system"
    }
}
