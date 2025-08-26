//
//  VoiceMessageBubble.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//
import SwiftUI

struct VoiceMessageBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            Image(systemName: "mic.fill")
            Text(message.voiceDuration ?? "0:00")
            Image(systemName: "play.fill")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.purple.opacity(0.2))
        )
    }
}
