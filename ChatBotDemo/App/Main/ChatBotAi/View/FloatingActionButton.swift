//
//  FloatingActionButton.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//

import SwiftUI

struct FloatingActionButton: View {
    @State private var isExpanded = false
    @State private var showPulse = true
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                ZStack {
                    // Pulse Animation
                    if showPulse {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 56, height: 56)
                            .scaleEffect(showPulse ? 1.5 : 1)
                            .opacity(showPulse ? 0 : 1)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: false),
                                value: showPulse
                            )
                    }
                    
                    Button(action: { isExpanded.toggle() }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "arrow.up")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        }
                        .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    FloatingActionButton()
}
