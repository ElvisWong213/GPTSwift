//
//  ChatView.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel = ChatViewModel()
        
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages) { message in
                        ForEach(message.content) { content in
                            Chatbubble(author: message.author, content: content)
                        }
                    }
                }                                        
                .rotationEffect(.degrees(180))
            }
            .scrollIndicators(.never)
            .rotationEffect(.degrees(180))
            ChatInputTextField()
                .environmentObject(viewModel)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    ChatView()
}
