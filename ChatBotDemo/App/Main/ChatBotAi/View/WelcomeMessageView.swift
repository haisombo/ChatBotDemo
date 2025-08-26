//
//  WelcomeMessageView.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//

import SwiftUI

struct WelcomeMessageView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Hello! I'm your AI-powered")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            Text("assistant. Choose the options ")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            Text("below or ask me anything.")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            
            // Animated Divider
//            HStack(spacing: 8) {
//                ForEach(0..<3) { index in
//                    Circle()
//                        .fill(Color.black.opacity(0.5))
//                        .frame(width: 4, height: 4)
//                        .scaleEffect(isAnimating ? 1.2 : 0.8)
//                        .animation(
//                            Animation.easeInOut(duration: 0.6)
//                                .repeatForever()
//                                .delay(Double(index) * 0.2),
//                            value: isAnimating
//                        )
//                }
//            }
//            .onAppear { isAnimating = true }
        }
        .padding(.vertical, 20)
    }
}
