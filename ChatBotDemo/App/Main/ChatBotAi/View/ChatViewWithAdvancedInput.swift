//
//  ChatViewWithAdvancedInput.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//
import SwiftUI

struct ChatViewWithAdvancedInput: View {
    @State private var messageText = ""
    @StateObject private var viewModel = ChatViewModel() // Added ViewModel
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.45, green: 0.3, blue: 0.9),
                    Color(red: 0.7, green: 0.4, blue: 0.95),
                    Color(red: 0.9, green: 0.5, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                chatHeader
                
                // Messages using ViewModel
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        // Auto-scroll to latest message
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                // Advanced Input Bar with ViewModel
                AdvancedInputBar(
                    text: $messageText,
                    viewModel: viewModel,
                    onSend: {
                        // Optional: Additional actions after sending
                        print("Message sent via AdvancedInputBar")
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Messages are already loaded in ViewModel's init
            print("Chat view appeared with \(viewModel.messages.count) messages")
        }
    }
    
    private var chatHeader: some View {
        HStack {
            // Avatar/Status indicator
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("WeBill365 Virtual Assistant")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("Online")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Menu button
            Menu {
                Button(action: { viewModel.clearChat() }) {
                    Label("Clear Chat", systemImage: "trash")
                }
                
                Button(action: {
                    let exportedText = viewModel.exportChat()
                    print(exportedText)
                }) {
                    Label("Export Chat", systemImage: "square.and.arrow.up")
                }
                
                Button(action: {}) {
                    Label("Settings", systemImage: "gear")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Button(action: {}) {
                Image(systemName: "xmark")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(
            Color.black.opacity(0.2)
                .background(.ultraThinMaterial)
        )
    }
}

// MARK: - Alternative Implementation (if you want to keep it simple without ViewModel)
struct SimpleChatViewWithAdvancedInput: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @StateObject private var temporaryViewModel = ChatViewModel() // Temporary ViewModel just for AdvancedInputBar
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.45, green: 0.3, blue: 0.9),
                    Color(red: 0.7, green: 0.4, blue: 0.95),
                    Color(red: 0.9, green: 0.5, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                chatHeader
                
                // Messages
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubbleView(message: message)
                        }
                    }
                    .padding()
                }
                
                // Advanced Input Bar
                AdvancedInputBar(
                    text: $messageText,
                    viewModel: temporaryViewModel,
                    onSend: sendMessage
                )
            }
        }
        .preferredColorScheme(.dark)
        .onReceive(temporaryViewModel.$messages) { newMessages in
            // Sync messages from ViewModel to local state
            if !newMessages.isEmpty && newMessages.count > messages.count {
                messages = newMessages
            }
        }
    }
    
    private var chatHeader: some View {
        HStack {
            Image(systemName: "message.circle.fill")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("WeBill365 Virtual Assistant")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "xmark")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        // Create message without timestamp parameter
        let newMessage = ChatMessage(
            content: messageText,
            isUser: true,
            type: .text // Specify type
        )
        
        withAnimation {
            messages.append(newMessage)
            messageText = ""
        }
        
        // Simulate bot response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let botMessage = ChatMessage(
                content: "I understand your question. Let me help you with that.",
                isUser: false,
                type: .text
            )
            withAnimation {
                messages.append(botMessage)
            }
        }
    }
}
//struct ChatViewWithAdvancedInput: View {
//    @State private var messageText = ""
//    @State private var messages: [ChatMessage] = []
//    
//    var body: some View {
//        ZStack {
//            // Background gradient
//            LinearGradient(
//                colors: [
//                    Color(red: 0.45, green: 0.3, blue: 0.9),
//                    Color(red: 0.7, green: 0.4, blue: 0.95),
//                    Color(red: 0.9, green: 0.5, blue: 0.8)
//                ],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // Header
//                chatHeader
//                
//                // Messages
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach(messages) { message in
//                            MessageBubbleView(message: message)
//                        }
//                    }
//                    .padding()
//                }
//                
//                // Advanced Input Bar
//                AdvancedInputBar(
//                    text: $messageText,
//                    onSend: sendMessage
//                )
//            }
//        }
//        .preferredColorScheme(.dark)
//    }
//    
//    private var chatHeader: some View {
//        HStack {
//            Image(systemName: "message.circle.fill")
//                .font(.title2)
//                .foregroundColor(.white)
//            
//            Text("WeBill365 Virtual Assistant")
//                .font(.headline)
//                .foregroundColor(.white)
//            
//            Spacer()
//            
//            Button(action: {}) {
//                Image(systemName: "xmark")
//                    .foregroundColor(.white.opacity(0.8))
//            }
//        }
//        .padding()
//        .background(Color.black.opacity(0.2))
//    }
//    
//    private func sendMessage() {
//        guard !messageText.isEmpty else { return }
//        
//        let newMessage = ChatMessage(
//            content: messageText,
//            isUser: true,
//            timestamp: Date()
//        )
//        
//        withAnimation {
//            messages.append(newMessage)
//            messageText = ""
//        }
//        
//        // Simulate bot response
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            let botMessage = ChatMessage(
//                content: "I understand your question. Let me help you with that.",
//                isUser: false,
//                timestamp: Date()
//            )
//            withAnimation {
//                messages.append(botMessage)
//            }
//        }
//    }
//}
