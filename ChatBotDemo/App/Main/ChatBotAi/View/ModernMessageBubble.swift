//
//  ModernMessageBubble.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//

import SwiftUI

struct ModernMessageBubble: View {
    let message: ChatMessageNew
    let showTranslation: Bool
    let targetLanguage: String
    @State private var translatedText = ""
    @State private var showOriginal = true
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
            }
            
            // Message Bubble
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Main Message Container
                Text(showOriginal ? message.content : translatedText)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(message.isUser ? .white : Color(red: 0.2, green: 0.2, blue: 0.2))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                message.isUser ?
                                // User message - soft purple gradient
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.6, green: 0.5, blue: 0.9),  // Soft purple
                                        Color(red: 0.7, green: 0.6, blue: 0.95)  // Light purple
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                // AI message - white with subtle shadow
                                LinearGradient(
                                    colors: [Color.clear, Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        // Border for AI messages only
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                message.isUser ? Color.clear : Color.clear,
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: message.isUser ?
                            Color.purple.opacity(0.2) :
                            Color.black.opacity(0.08),
                        radius: message.isUser ? 8 : 4,
                        x: 0,
                        y: 2
                    )
                
                // Translation Toggle (if needed)
                if showTranslation && !translatedText.isEmpty {
                    Button(action: { showOriginal.toggle() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                                .font(.system(size: 10))
                            Text(showOriginal ? "Translate" : "Original")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.gray)
                    }
                }
            }
            
            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .onAppear {
            if showTranslation {
                translateMessage()
            }
        }
        .onChange(of: showTranslation) { _ in
            if showTranslation {
                translateMessage()
            }
        }
    }
    
    private func translateMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            translatedText = "[Translated to \(targetLanguage)] \(message.content)"
        }
    }
}
