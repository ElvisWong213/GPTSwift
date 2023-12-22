//
//  ChatInputTextField.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif
import SwiftData

struct ChatInputTextField: View {
    @Bindable var chatViewModel: ChatViewModel
    @State var selectedItem: PhotosPickerItem?
    @State var uiImage: UIImage?
    
    var body: some View {
        HStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Image(systemName: "plus")
                    .font(.title2)
            }
            VStack {
                if let uiImage = uiImage {
                    Button {
                        self.uiImage = nil
                        self.selectedItem = nil
                    } label: {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                }
                TextField("Message", text: $chatViewModel.textInput, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button {
                sendMessage()
            } label: {
                if chatViewModel.isSent {
                    Image(systemName: "ellipsis")
                        .symbolEffect(.pulse)
                } else {
                    Image(systemName: "arrow.up.circle")
                }
            }
            .font(.title2)
            .disabled(chatViewModel.textInput.isEmpty || chatViewModel.isSent)
        }
        .padding()
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    uiImage = UIImage(data: data)
                    uiImage = uiImage?.resize(512, 512)
                }
            }
        }
    }
    
    private func sendMessage() {
        var contents: [MyContent] = []
        if let image = uiImage {
            contents.append(MyContent(type: .Image, value: image.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""))
        }
        contents.append(MyContent(type: .Text, value: chatViewModel.textInput))
        let newMessage = MyMessage(author: .User, contents: contents)
        
        // Clear input
        chatViewModel.textInput = ""
        selectedItem = nil
        uiImage = nil
        chatViewModel.sendMessage(newMessage: newMessage)
    }
}

#Preview {
    ChatInputTextField(chatViewModel: ChatViewModel(modelContext: ModelContext(try! ModelContainer(for: Chat.self)), chat: Chat(title: "")))
}
