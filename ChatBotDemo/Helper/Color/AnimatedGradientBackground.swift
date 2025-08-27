//
//  AnimatedGradientBackground.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//

import SwiftUI

struct AnimatedGradientBackground: View {
    
    @State private var animateGradient = false
    
    // Light pastel colors - visible but still soft
    let colors1 = [
        Color(red: 0.94, green: 0.92, blue: 1.0),   // #F0EBFF - Light lavender
        Color(red: 1.0, green: 0.94, blue: 0.96),   // #FFEFF5 - Light pink
        Color(red: 0.92, green: 0.95, blue: 1.0)    // #EBF2FF - Light blue
    ]
    
    let colors2 = [
        Color(red: 0.96, green: 0.92, blue: 1.0),   // #F5EBFF - Soft purple
        Color(red: 1.0, green: 0.95, blue: 0.94),   // #FFF2F0 - Soft peach
        Color(red: 0.94, green: 0.94, blue: 1.0)    // #F0F0FF - Soft periwinkle
    ]
    
    var body: some View {
        LinearGradient(
            colors: animateGradient ? colors1 : colors2,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
        .overlay(
            // Subtle mesh gradient effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 300
                        )
                    )
                    .blur(radius: 60)
                    .offset(x: 100, y: -150)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.pink.opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 300
                        )
                    )
                    .blur(radius: 60)
                    .offset(x: -100, y: 150)
            }
        )
    }
}

struct RadialGradientBackground: View {
    var body: some View {
        ZStack {
            // Base white background
            Color.white
            
            // Radial gradient overlay with hex colors
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "FF6700").opacity(0.30), location: 0.0),
                    .init(color: Color(hex: "8469FF").opacity(0.19), location: 0.4),
                    .init(color: Color(hex: "FFFFFF").opacity(0.245), location: 1.0)
                ]),
                center: .top,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.8
            )
            .ignoresSafeArea()
            
            // Additional subtle overlay for depth
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.0),
                    Color.white.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
