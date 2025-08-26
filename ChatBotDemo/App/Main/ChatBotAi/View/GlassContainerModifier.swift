//
//  GlassContainerModifier.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//
import SwiftUI

struct GlassContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(glassBorder)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private var glassBorder: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.6),
                        Color.white.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
    }
}
