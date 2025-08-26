//
//  MessageTextView.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//
import SwiftUI

struct MessageTextView: View {
    let content: String
    let isUser: Bool
    @Binding var isExpanded: Bool
    let maxLength: Int
    
    private var displayText: String {
        if content.count > maxLength && !isExpanded {
            return String(content.prefix(maxLength)) + "..."
        }
        return content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(displayText)
                .font(.system(size: 15))
                .foregroundColor(isUser ? .white : .primary)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(isUser ?
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isUser ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            if content.count > maxLength {
                Button(action: { isExpanded.toggle() }) {
                    Text(isExpanded ? "Show less" : "Show more")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
