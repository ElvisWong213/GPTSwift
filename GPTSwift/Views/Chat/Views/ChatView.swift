//
//  ChatView.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import SwiftUI
import SwiftData

struct ChatView: View {
    @State private var viewModel: ChatViewModel
    private let errorMessageId: UUID = UUID()
    private var latestMessage: MyContent? {
        get {
            viewModel.getLatestMessage()?.contents.last
        }
    }
    
    init(modelContext: ModelContext, chatId: UUID, isTempMessage: Bool = false) {
        let viewModel = ChatViewModel(modelContext: modelContext, chatId: chatId, isTempMessage: isTempMessage)
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ZStack {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            allMessages()
                            errorMessage()
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                    .onChange(of: viewModel.errorMessage) {
                        if !viewModel.errorMessage.isEmpty {
                            proxy.scrollTo(errorMessageId, anchor: .bottom)
                        }
                    }
                    .onChange(of: latestMessage?.value) {
                        proxy.scrollTo(latestMessage?.id, anchor: .bottom)
                    }
                    .onAppear() {
                        proxy.scrollTo(latestMessage?.id, anchor: .bottom)
                    }
                    gotoBottomButton(proxy)
                }
            }
            .scrollIndicators(.automatic)
            .listStyle(.plain)
            .overlay {
                switch viewModel.chatState {
                case .FetchingDatabase:
                    ProgressView()
                case .Empty:
                    Text("Send a message to ChatGPT")
                case .Done, .FetchingAPI:
                    EmptyView()
                }
            }
            ChatInputTextField(chatViewModel: viewModel)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    EditChatView(editChat: viewModel.chat)
                } label: {
                    Text("Edit")
                        .fixedSize()
                }
            }
        }
        .onDisappear() {
            viewModel.removeChat()
        }
#if os(iOS)
        .toolbar(.hidden, for: .tabBar)
#endif
    }
    
    @ViewBuilder private func contextMenuButtons(message: MyMessage, content: MyContent) -> some View {
        Button {
            CopyService.copy(content.value)
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }
        Button(role: .destructive) {
            viewModel.removeMessage(message: message)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    @ViewBuilder private func allMessages() -> some View {
        ForEach(viewModel.sortMessages()) { message in
            ForEach(message.contents) { content in
                Chatbubble(author: message.author, messageType: content.type, value: content.value, chatState: viewModel.chatState, isLatest: message.isLatest)
                    .id(content.id)
                    .contextMenu {
                        contextMenuButtons(message: message, content: content)
                    }
            }
        }
    }
    
    @ViewBuilder private func errorMessage() -> some View {
        if !viewModel.errorMessage.isEmpty {
            Chatbubble(author: .Error, messageType: .Text, value: viewModel.errorMessage, chatState: .Done)
                .id(errorMessageId)
                .listRowSeparator(.hidden)
        }
    }
    
    @ViewBuilder private func gotoBottomButton(_ proxy: ScrollViewProxy) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        proxy.scrollTo(latestMessage?.id, anchor: .bottom)
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.blue)
                        .padding(10)
                        .background() {
                            Circle()
                                .fill(.white.opacity(0.7))
                                .shadow(radius: 5)
                        }
                }
                .padding()
                .buttonStyle(.plain)
            }
        }
    }
}

#if DEBUG
#Preview {
    ChatView(modelContext: SwiftDataService.previewData.mainContext, chatId: Chat.MOCK.id)
        .modelContainer(SwiftDataService.previewData)
}
#endif
