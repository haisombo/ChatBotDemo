//
//  View.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 27/8/25.
//

import SwiftUI

// Extension for easy use
extension View {
    func liquidGlass(cornerRadius: CGFloat = 20, material: Material = .ultraThinMaterial) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, material: material))
    }
}
