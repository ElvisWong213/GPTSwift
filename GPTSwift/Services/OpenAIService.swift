//
//  OpenAIService.swift
//  GPTSwift
//
//  Created by Elvis on 22/12/2023.
//

import Foundation
import OpenAI

class OpenAIService {
    static let openAI = OpenAI(apiToken: KeychainService.getKey())
}
