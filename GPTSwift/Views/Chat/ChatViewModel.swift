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
        let promptMessage = Message(role: .system, content: .object([ChatContent(type: .text, value: chat.prompt)]))
        var messages = chat.messages.sorted(by: { $0.timestamp < $1.timestamp } ).map{ $0.convertToMessage() }
        messages.insert(promptMessage, at: 0)
        
        let chatQuery = ChatQuery(model: chat.model!, messages: messages, maxTokens: chat.maxToken)
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
            case .failure(let error):
                print(error)
                self.getErrorMessage(errorResponse: error as! APIErrorResponse, newMessage: newMessage)
                self.updateIsSent(false)
            }
        } completion: { error in
            if let error {
                print(error)
            }
            self.updateIsSent(false)
            newMessage.timestamp = Date.now
            try? self.modelContext.save()
            print("Save")
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
        }
    }
    
    func removeMessage(message: MyMessage) {
        chat.messages.removeAll(where: { $0.id == message.id })
        modelContext.delete(message)
        try? modelContext.save()
    }
    
    func removeAllMessage() {
        for message in chat.messages {
            modelContext.delete(message)
        }
        try? modelContext.save()
    }
    
    func sortMessages() -> [MyMessage] {
        return chat.messages.sorted(by: { $0.timestamp < $1.timestamp })
    }
}
