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
import AVFoundation

struct ChatInputTextField: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
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
                setUpMessage()
                chatViewModel.sendMessage()
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
    
    private func setUpMessage() {
        var content: [MyContent] = []
        if let image = uiImage {
            content.append(MyContent(type: .Image, value: image.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""))
        }
        content.append(MyContent(type: .Text, value: chatViewModel.textInput))
        chatViewModel.messages.append(.init(author: .User, content: content))
        
        // Clear input
        chatViewModel.textInput = ""
        selectedItem = nil
        uiImage = nil
    }
}

#Preview {
    ChatInputTextField()
        .environmentObject(ChatViewModel())
}

public extension UIImage {
    /// Resize image while keeping the aspect ratio. Original image is not modified.
    /// - Parameters:
    ///   - width: A new width in pixels.
    ///   - height: A new height in pixels.
    /// - Returns: Resized image.
    func resize(_ width: Int, _ height: Int) -> UIImage {
        // Keep aspect ratio
        let maxSize = CGSize(width: width, height: height)

        let availableRect = AVFoundation.AVMakeRect(
            aspectRatio: self.size,
            insideRect: .init(origin: .zero, size: maxSize)
        )
        let targetSize = availableRect.size

        // Set scale of renderer so that 1pt == 1px
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        // Resize the image
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resized
    }
}
