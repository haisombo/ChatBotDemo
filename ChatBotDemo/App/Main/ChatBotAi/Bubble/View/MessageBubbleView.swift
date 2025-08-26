//
//  MessageBubbleView.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//
import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
            // Option 1: Use with isUser parameter
            if let images = message.images, !images.isEmpty {
                MessageImagesGrid(
                    images: images,
                    isUser: message.isUser
                )
            }
            
            // Option 2: Use with full message (if you prefer)
            // if let images = message.images, !images.isEmpty {
            //     MessageImagesGridWithMessage(
            //         images: images,
            //         message: message
            //     )
            // }
            
            // Message text
            if !message.content.isEmpty {
                Text(message.content)
                    .font(.system(size: 14))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                message.isUser ?
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [
                                        Color.gray.opacity(0.1),
                                        Color.gray.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
            
            // Timestamp
            Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundColor(.gray.opacity(0.5))
        }
    }
}
