//
//  ChatInputTextField.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI
import PhotosUI
import SwiftData
import OpenAI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct ChatInputTextField: View {
    @Bindable var chatViewModel: ChatViewModel
    @State var selectedItem: PhotosPickerItem?
#if os(iOS)
    @State var uiImage: UIImage?
#elseif os(macOS)
    @State var nsimage: NSImage?
#endif
    
    var body: some View {
        HStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Image(systemName: "plus")
                    .font(.title2)
            }
            .disabled(chatViewModel.chat?.model != .gpt4_vision_preview)
            VStack {
#if os(iOS)
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
#elseif os(macOS)
                if let nsimage = nsimage {
                    Button {
                        self.nsimage = nil
                        self.selectedItem = nil
                    } label: {
                        Image(nsImage: nsimage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                }
#endif
                TextField("Message", text: $chatViewModel.textInput, axis: .vertical)
                    .lineLimit(5)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .overlay() {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray, lineWidth: 1)
                    }
                    .textFieldStyle(.plain)
                    .onSubmit {
                        sendMessage()
                    }
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
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onChange(of: selectedItem) {
            resizeImage()
        }
    }
}

extension ChatInputTextField {
    private func sendMessage() {
        guard !chatViewModel.textInput.isEmpty && !chatViewModel.isSent else {
            print("Debug: Unable to send Message (text field is empty or gpt is responding)")
            return
        }
        
        var contents: [MyContent] = []
        
#if os(iOS)
        if let image = uiImage {
            contents.append(MyContent(type: .Image, value: image.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""))
        }
#elseif os(macOS)
        if let image = nsimage {
            guard let imageData = image.tiffRepresentation else {
                print("DEBUG: Cannot convert NSImage to image data")
                return
            }
            let bitmap = NSBitmapImageRep(data: imageData)
            let pngData = bitmap?.representation(using: .png, properties: [:])
            contents.append(MyContent(type: .Image, value: pngData?.base64EncodedString() ?? ""))
        }
#endif
        
        contents.append(MyContent(type: .Text, value: chatViewModel.textInput))
        let newMessage = MyMessage(author: .User, contents: contents)
        
        // Clear input
        chatViewModel.textInput = ""
        selectedItem = nil
#if os(iOS)
        uiImage = nil
#elseif os(macOS)
        nsimage = nil
#endif
        chatViewModel.sendMessage(newMessage: newMessage)
    }
    
    private func resizeImage() {
        Task {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
#if os(iOS)
                uiImage = UIImage(data: data)
                uiImage = uiImage?.resize(512, 512)
#elseif os(macOS)
                nsimage = NSImage(data: data)
                nsimage = nsimage?.resize(512, 512)
#endif
            }
        }
    }
}

#Preview {
    ChatInputTextField(chatViewModel: ChatViewModel(modelContext: ModelContext(try! ModelContainer(for: Chat.self)), chatId: Chat(title: "").id, isTempMessage: false))
}
