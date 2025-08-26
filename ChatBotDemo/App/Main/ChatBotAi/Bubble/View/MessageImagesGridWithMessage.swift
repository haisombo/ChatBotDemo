//
//  MessageImagesGridWithMessage.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//
import SwiftUI

struct MessageImagesGridWithMessage: View {
    
    let images: [UIImage]
    let message: ChatMessage
    
    var body: some View {
        VStack(spacing: 8) {
            if images.count == 1 {
                // Single image
                Image(uiImage: images[0])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 250, maxHeight: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if images.count == 2 {
                // Two images side by side
                HStack(spacing: 4) {
                    ForEach(0..<2) { index in
                        Image(uiImage: images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            } else {
                // Grid for 3+ images
                LazyVGrid(columns: [GridItem(.fixed(80)), GridItem(.fixed(80)), GridItem(.fixed(80))], spacing: 4) {
                    ForEach(Array(images.prefix(9).enumerated()), id: \.offset) { index, image in
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            
                            // Show "+X" for remaining images
                            if index == 8 && images.count > 9 {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.black.opacity(0.6))
                                Text("+\(images.count - 9)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, message.isUser ? 0 : 8)
    }
}
