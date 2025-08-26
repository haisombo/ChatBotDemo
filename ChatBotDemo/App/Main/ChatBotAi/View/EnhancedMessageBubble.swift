//
//  EnhancedMessageBubble.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//

import SwiftUI

struct EnhancedMessageBubble: View {
    let message: ChatMessage
    @State private var showImageViewer = false
    @State private var selectedImage: UIImage?
    @State private var expandedText = false
    
    private let maxTextLength = 500
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !message.isUser {
                // AI Avatar
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("AI")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            if message.isUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                // Typing Indicator
                if message.isTyping {
                    TypingIndicatorView()
                } else {
                    // File Attachments
                    if let files = message.attachedFiles, !files.isEmpty {
                        FileAttachmentsView(files: files)
                    }
                    
                    // Image Grid
                    if let images = message.images, !images.isEmpty {
                        ImageGridView(
                            images: images,
                            onImageTap: { image in
                                selectedImage = image
                                showImageViewer = true
                            }
                        )
                    }
                    
                    // Text Content
                    if !message.content.isEmpty {
                        MessageTextView(
                            content: message.content,
                            isUser: message.isUser,
                            isExpanded: $expandedText,
                            maxLength: maxTextLength
                        )
                    }
                    
                    // Timestamp
                    Text(formatTimestamp(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer(minLength: 50)
            }
            
            if message.isUser {
                // User Avatar
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.orange, Color.pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .sheet(isPresented: $showImageViewer) {
            if let image = selectedImage {
                ImageViewerSheet(image: image)
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
