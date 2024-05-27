//
//  OpenAIService.swift
//  GPTSwift
//
//  Created by Elvis on 22/12/2023.
//

import Foundation
import OpenAI

class OpenAIService {
//    static let shared: OpenAIService = {
//        let instance = OpenAIService()
//        return instance
//    }()
    
    static let availableModels: [Model] = [
        .gpt4, .gpt4_32k, .gpt4_0613, .gpt4_turbo, .gpt4_32k_0613, .gpt4_0125_preview,
        .gpt4_o, .gpt4_vision_preview,
        .gpt3_5Turbo, .gpt3_5Turbo_16k, .gpt3_5Turbo_0125, .gpt3_5Turbo_16k_0613
    ]
    
//    private init() {
//        Task {
//            self.availableModels = await self.fetchAvailableModels()
//        }
//    }
    
//    func fetchAvailableModels() async -> [ModelResult] {
//        let openAI = OpenAI(apiToken: KeychainService.getKey())
//        let result = try? await openAI.models()
//        var openAIModels = result?.data.sorted(by: { $0.id < $1.id }) ?? []
//        openAIModels = openAIModels.filter{ $0.id.contains("gpt") }
//        return openAIModels
//    }
}
