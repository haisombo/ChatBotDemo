//
//  CardMessageBubble.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//

import SwiftUI

struct CardMessageBubble: View {
    let message: ChatMessage
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = message.cardTitle {
                Text(title)
                    .font(.headline)
            }
            if let subtitle = message.cardSubtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            if let actions = message.cardActions {
                HStack {
                    ForEach(actions) { action in
                        Button(action.title, action: action.action)
                            .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }
}
