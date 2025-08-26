//
//  GlassmorphicHeaderView.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//

import SwiftUI

struct GlassmorphicHeaderView: View {
    
    @Binding var showTranslation: Bool
    @Binding var selectedLanguage: String
    @State private var showLanguagePicker = false
    
    var body: some View {
        HStack {
            // Logo with Glow Effect
            
            ZStack {
                Circle()
//                    .fill(
//                        LinearGradient(
//                            colors: [Color.purple, Color.blue],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
                    .frame(width: 36, height: 36)
                    .overlay(
//                        Text("We")
//                            .font(.system(size: 14, weight: .bold, design: .rounded))
//                            .foregroundColor(.black)
                        Image("ico_webill365")
                            .resizable()
                    )
//                    .shadow(color: .purple.opacity(0.5), radius: 10)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("WeBill365 Virtual Assistant")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                
            }
            
            Spacer()
            
            // Translation Toggle
//            Button(action: { showTranslation.toggle() }) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(
//                            LinearGradient(
//                                colors: showTranslation ?
//                                    [Color.blue, Color.purple] :
//                                    [Color.white.opacity(0.1), Color.white.opacity(0.05)],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .frame(width: 44, height: 28)
//                    
//                    Image(systemName: "translate")
//                        .font(.system(size: 14))
//                        .foregroundColor(.white)
//                }
//            }
//            .shadow(color: showTranslation ? .blue.opacity(0.5) : .clear, radius: 8)
            
            // Language Selector
//            Button(action: { showLanguagePicker.toggle() }) {
//                Text(selectedLanguage)
//                    .font(.system(size: 12, weight: .medium))
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(
//                        Capsule()
//                            .fill(Color.white.opacity(0.2))
//                    )
//            }
            
//            Button(action: {}) {
//                Image(systemName: "minus")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.black.opacity(0.8))
//                    .frame(width: 28, height: 28)
//                    .background(Color.white.opacity(0.1))
//                    .clipShape(Circle())
//            }
            
            // Close Buttond
            Button(action: {
                //dismiss
            }) {
                Image("ico_close_16")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.black.opacity(0.8))
                    .frame(width: 32, height: 32)
//                    .background(Color.white.opacity(0.1))
//                    .clipShape(Circle())
            }
        }
        .padding()
//        .background(
//            GlassBackground(intensity: 0.5)
//        )
    }
}


