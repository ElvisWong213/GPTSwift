//
//  OpenAIService.swift
//  GPTSwift
//
//  Created by Elvis on 22/12/2023.
//

import Foundation
import OpenAI

class OpenAIService {
    static let shared: OpenAIService = {
        let instance = OpenAIService()
        return instance
    }()
    
    var availableModels: [ModelResult] = []
    
    private init() {
        Task {
            self.availableModels = await self.fetchAvailableModels()
        }
    }
    
    func fetchAvailableModels() async -> [ModelResult] {
        let openAI = OpenAI(apiToken: KeychainService.getKey())
        let result = try? await openAI.models()
        var openAIModels = result?.data.sorted(by: { $0.id < $1.id }) ?? []
        openAIModels = openAIModels.filter{ $0.id.contains("gpt") }
        return openAIModels
    }
}
