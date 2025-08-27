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
        }
        .padding(.vertical, 20)
    }
}
