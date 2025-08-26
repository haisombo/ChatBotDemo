//
//  OptionsMessageBubble.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//

import SwiftUI

struct OptionsMessageBubble: View {
    let message: ChatMessage
    var body: some View {
        if let options = message.options {
            VStack(alignment: .leading, spacing: 8) {
                if !message.content.isEmpty {
                    Text(message.content)
                        .font(.subheadline)
                }
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        print("Selected option: \(option)")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
}

