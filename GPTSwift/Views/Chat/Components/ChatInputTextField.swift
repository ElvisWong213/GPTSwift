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
    enum FocusedField {
        case message
    }
    
    @Bindable var chatViewModel: ChatViewModel
    @State var selectedItem: PhotosPickerItem?
    @FocusState private var focusedField: FocusedField?
#if os(iOS)
    @State var uiImage: UIImage?
#elseif os(macOS)
    @State var nsimage: NSImage?
#endif
    
    var body: some View {
        VStack {
            HStack {
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
            }
            HStack {
                if ((chatViewModel.chat?.isSupportImage()) != nil) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "plus")
                        .font(.title2)
                    }
                }
                TextField("Message", text: $chatViewModel.textInput, axis: .vertical)
                    .focused($focusedField, equals: .message)
                    .lineLimit(5)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        sendMessage()
                    }
                    .overlay() {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray, lineWidth: 1)
                    }
                Button {
                    sendMessage()
                } label: {
                    if chatViewModel.chatState == .FetchingAPI {
                        Image(systemName: "ellipsis")
                            .symbolEffect(.pulse)
                    } else {
                        Image(systemName: "arrow.up.circle")
                    }
                }
                .font(.title2)
                .disabled(chatViewModel.textInput.isEmpty || chatViewModel.chatState == .FetchingAPI)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onChange(of: selectedItem) {
            resizeImage()
        }
        .onAppear() {
            focusedField = .message
        }
    }
}

extension ChatInputTextField {
    private func sendMessage() {
        guard !chatViewModel.textInput.isEmpty && chatViewModel.chatState != .FetchingAPI else {
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
            let jpegData = bitmap?.representation(using: .jpeg, properties: [:])
            contents.append(MyContent(type: .Image, value: jpegData?.base64EncodedString() ?? ""))
        }
#endif
        
        let newMessage = MyMessage(author: .User, contents: [], isLatest: false)
        contents.append(MyContent(type: .Text, value: chatViewModel.textInput))
        newMessage.contents = contents
        
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

#if DEBUG
#Preview {
    ChatInputTextField(chatViewModel: ChatViewModel(modelContext: ModelContext(try! ModelContainer(for: Chat.self)), chatId: Chat(title: "").id, isTempMessage: false))
}
#endif
