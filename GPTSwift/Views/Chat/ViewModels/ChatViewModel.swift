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
    var modelContext: ModelContext
    var chatId: UUID
    var chat: Chat?
    var textInput: String = ""
    var errorMessage: String = ""
    let isTempMessage: Bool
    var chatState: ChatState = .Empty
    
    init(modelContext: ModelContext, chatId: UUID, isTempMessage: Bool) {
        self.modelContext = modelContext
        self.chatId = chatId
        self.isTempMessage = isTempMessage
        self.fetchData()
    }
    
    func sendMessage(newMessage: MyMessage) {
        guard let chat = chat else {
            print("DEBUG: Chat is empty")
            return
        }
        updateChatState(.FetchingAPI)
        errorMessage = ""
        // User message
        chat.messages.append(newMessage)
        let openAI = OpenAI(apiToken: KeychainService.getKey())
        let promptMessage = ChatQuery.ChatCompletionMessageParam.system(.init(content: chat.prompt))
        var messages = chat.messages.sorted(by: { $0.timestamp < $1.timestamp } ).flatMap{ $0.convertToMessage() }
        messages.insert(promptMessage, at: 0)
        
        guard let model = chat.model else {
            print("DEBUG: Chat model is empty")
            return
        }
        
        let chatQuery = ChatQuery(messages: messages, model: model, maxTokens: chat.maxToken)
        
        // debug
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(chatQuery)
        print(String(data: data!, encoding: .utf8) ?? "")
        
        // API response
        let responseMessage = MyMessage(author: .GPT, contents: [MyContent(type: .Text, value: "")], chat: chat)
        chat.messages.append(responseMessage)
        
        openAI.chatsStream(query: chatQuery) { response in
            switch response {
            case .success(let data):
                for choice in data.choices {
                    self.updateMessageContent(newMessage: responseMessage, content: choice.delta.content ?? "")
                }
            case .failure(let error):
                print(error)
                if let apiError = error as? APIErrorResponse {
                    self.getErrorMessage(errorResponse: apiError, newMessage: responseMessage)
                }
            }
        } completion: { error in
            if let error {
                print(error)
            }
            DispatchQueue.main.async {
                self.updateChatState(.Done)
                self.chat?.updateDate = Date.now
                self.updateMessageIsLatest(message: responseMessage)
                self.createChatTitle()
                if !self.isTempMessage {
                    try? self.modelContext.save()
                    print("Save")
                }
            }
        }
    }
    
    private func updateMessageContent(newMessage: MyMessage, content: String) {
        DispatchQueue.main.async {
            newMessage.contents.first?.value.append(content)
        }
    }
    
    private func updateChatState(_ state: ChatState) {
        DispatchQueue.main.async {
            self.chatState = state
        }
    }
    
    private func updateMessageIsLatest(message: MyMessage) {
        DispatchQueue.main.async {
            message.isLatest = false
        }
    }
    
    private func getErrorMessage(errorResponse: APIErrorResponse, newMessage: MyMessage) {
        guard let chat = chat else {
            print("DEBUG: Chat is empty")
            return
        }
        DispatchQueue.main.async {
            self.errorMessage = errorResponse.error.message
            chat.messages.removeAll(where: { $0.id == newMessage.id })
        }
    }
    
    private func createChatTitle() {
        guard chat != nil, chat!.title.isEmpty && chat!.messages.count >= 2 else {
            return
        }
        for message in sortMessages() {
            if message.author == .GPT {
                let firstResponseMessage: String = message.contents.first?.value ?? ""
                chat?.title = String(firstResponseMessage.prefix(35)) + "..."
                break
            }
        }
    }
    
    private func fetchData() {
        chatState = .FetchingDatabase
        let predicate = #Predicate<Chat>{ $0.id == chatId }
        let descriptor = FetchDescriptor<Chat>(predicate: predicate)
        do {
            let chats = try self.modelContext.fetch(descriptor)
            guard let fetchChat = chats.first else {
                print("DUBUG: Chats are empty")
                self.chatState = .Empty
                return
            }
            if fetchChat.messages.isEmpty {
                self.chatState = .Empty
            } else {
                self.chatState = .Done
            }
            self.chat = fetchChat
        } catch {
            print("DEBUG: Unable to fetch the chat -- \(self.chatId)")
            self.chatState = .Empty
        }
    }
    
    func removeMessage(message: MyMessage) {
        guard let chat = chat else {
            print("DEBUG: Chat is empty")
            return
        }
        chat.messages.removeAll(where: { $0.id == message.id })
        modelContext.delete(message)
        if !isTempMessage {
            try? modelContext.save()
        }
    }
    
    func removeAllMessage() {
        guard let chat = chat else {
            return
        }
        for message in chat.messages {
            modelContext.delete(message)
        }
        if !isTempMessage {
            try? modelContext.save()
        }
    }
    
    func sortMessages() -> [MyMessage] {
        guard let chat = chat else {
            print("DEBUG: Chat is empty")
            return []
        }
        return chat.messages.sorted(by: { $0.timestamp < $1.timestamp })
    }
    
    func getLatestMessage() -> MyMessage? {
        return sortMessages().last
    }
    
    func removeChat() {
        guard let chat = chat else {
            return
        }
        if chat.messages.isEmpty {
            modelContext.delete(chat)
            try? modelContext.save()
        }
    }
}

enum ChatState {
    case FetchingAPI, FetchingDatabase, Empty, Done
}
