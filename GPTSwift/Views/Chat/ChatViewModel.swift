//
//  ChatViewModel.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import Foundation
import OpenAI

class ChatViewModel: ObservableObject {
    @Published var textInput: String = ""
    @Published var isSent: Bool = false
    @Published var messages: [MyMessage] = []
    
    func sendMessage() {
        isSent = true
        let openAI = OpenAI(apiToken: KeychainService.getKey())
        let chatQuery = ChatQuery(model: .gpt3_5Turbo_1106, messages: messages.map{ $0.convertToMessage() })
        // debug
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(chatQuery)
        print(String(data: data!, encoding: .utf8) ?? "")
        
        messages.append(.init(author: .GPT, content: [MyContent(type: .Text, value: "")]))
        let index = messages.count - 1
        openAI.chatsStream(query: chatQuery) { response in
            switch response {
            case .success(let data):
                for choice in data.choices {
                    self.updateMessageContent(messageIndex: index, content: choice.delta.content ?? "")
                }
            case .failure(let error):
                print(error)
                self.updateIsSent(false)
            }
        } completion: { error in
            print(error?.localizedDescription ?? "")
            self.updateIsSent(false)
        }
    }
    
    private func updateMessageContent(messageIndex index: Int, content: String) {
        DispatchQueue.main.async {
            self.messages[index].content[0].value.append(content)
        }
    }
    
    private func updateIsSent(_ value: Bool) {
        DispatchQueue.main.async {
            self.isSent = value
        }
    }
}
