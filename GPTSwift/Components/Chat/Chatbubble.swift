//
//  Chatbubble.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI

struct Chatbubble: View {
    let author: Author
    var content: MyContent
    
    var body: some View {
        HStack {
            if author.isUser {
                Spacer()
            }
            VStack(alignment: author.isUser ? .trailing : .leading) {
                if content.type == .Text {
                    Text(LocalizedStringKey(content.value))
                        .textSelection(.enabled)
                        .foregroundStyle(.white)
                } else {
                    if let data = Data(base64Encoded: content.value) {
                        Image(uiImage: UIImage(data: data)!)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            .padding()
            .background() {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundStyle(author.isUser ? .blue : .gray)
            }
            if !author.isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.trailing, author.isUser ? 0 : 20)
        .padding(.leading, author.isUser ? 20 : 0)
    }
}

#Preview {
    ScrollView {
        ForEach(MyMessage.MOCK) { message in
            ForEach(message.content) { content in
                Chatbubble(author: message.author, content: content)
            }
        }
    }
}
