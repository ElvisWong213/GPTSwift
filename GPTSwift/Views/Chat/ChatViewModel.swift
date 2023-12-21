//
//  ChatViewModel.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import Foundation
import OpenAI
import SwiftData

@Observable
class ChatViewModel {
    let modelContext: ModelContext
    var chat: Chat
    var textInput: String = ""
    var isSent: Bool = false
    var errorMessage: String = ""
    
    init(modelContext: ModelContext, chat: Chat) {
        self.modelContext = modelContext
        self.chat = chat
    }
    
    func sendMessage(newMessage: MyMessage) {
        isSent = true
        errorMessage = ""
        chat.messages.append(newMessage)
        let openAI = OpenAI(apiToken: KeychainService.getKey())
        let chatQuery = ChatQuery(model: .gpt3_5Turbo_1106, messages: chat.messages.sorted(by: { $0.timestamp < $1.timestamp } ).map{ $0.convertToMessage() })
        // debug
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(chatQuery)
        print(String(data: data!, encoding: .utf8) ?? "")
        
        let newMessage = MyMessage(author: .GPT, contents: [MyContent(type: .Text, value: "")])
        
        chat.messages.append(newMessage)
        
        openAI.chatsStream(query: chatQuery) { response in
            switch response {
            case .success(let data):
                for choice in data.choices {
                    self.updateMessageContent(newMessage: newMessage, content: choice.delta.content ?? "")
                }
//                self.modelContext.insert(self.chat)
                try? self.modelContext.save()
            case .failure(let error):
                print(error)
                self.getErrorMessage(errorResponse: error as! APIErrorResponse, newMessage: newMessage)
                self.updateIsSent(false)
            }
        } completion: { error in
            print(error?.localizedDescription ?? "")
            self.updateIsSent(false)
        }
    }
    
    private func updateMessageContent(newMessage: MyMessage, content: String) {
        DispatchQueue.main.async {
            newMessage.contents.first?.value.append(content)
        }
    }
    
    private func updateIsSent(_ value: Bool) {
        DispatchQueue.main.async {
            self.isSent = value
        }
    }
    
    private func getErrorMessage(errorResponse: APIErrorResponse, newMessage: MyMessage) {
        DispatchQueue.main.async {
            self.errorMessage = errorResponse.error.message
            self.chat.messages.removeAll(where: { $0.id == newMessage.id })
            try? self.modelContext.save()
        }
    }
}
