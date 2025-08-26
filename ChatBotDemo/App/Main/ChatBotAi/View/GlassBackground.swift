//
//  GlassBackground.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//

import SwiftUI

struct GlassBackground: View {
    let intensity: Double
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.05)
            
            // Blur effect
            VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                .opacity(intensity)
        }
    }
}
