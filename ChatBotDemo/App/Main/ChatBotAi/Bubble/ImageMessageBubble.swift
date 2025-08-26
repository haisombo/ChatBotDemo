//
//  ImageMessageBubble.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//

import SwiftUI

struct ImageMessageBubble: View {
    let message: ChatMessage
    var body: some View {
        if let images = message.images {
            ImageGrid(images: images)
        }
    }
}

