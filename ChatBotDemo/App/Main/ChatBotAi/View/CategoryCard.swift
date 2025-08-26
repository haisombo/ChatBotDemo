//
//  CategoryCard.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//

import SwiftUI

//struct CategoryCard: View {
//    
//    let icon: String
//    let title: String
//    let action: () -> Void
//    @State private var isPressed = false
//    
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: 8) {
//                Image(systemName: icon)
//                    .font(.system(size: 24))
//                    .foregroundColor(.black)
//                    .frame(width: 50, height: 50)
//                    .background(
//                        Circle()
//                            .fill(
//                                LinearGradient(
//                                    colors: [
//                                        Color.white.opacity(0.2),
//                                        Color.white.opacity(0.05)
//                                    ],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                    )
//                
//                Text(title)
//                    .font(.system(size: 13, weight: .medium))
//                    .foregroundColor(.black)
//                    .lineLimit(2)
//                    .multilineTextAlignment(.center)
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 16)
//            .background(
//                RoundedRectangle(cornerRadius: 20, style: .continuous)
//                    .fill(Color.white.opacity(0.9))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 20, style: .continuous)
//                            .stroke(
//                                LinearGradient(
//                                    colors: [
//                                        Color.black.opacity(0.3),
//                                        Color.black.opacity(0.1)
//                                    ],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                ),
//                                lineWidth: 1
//                            )
//                    )
//            )
//            .scaleEffect(isPressed ? 0.95 : 1)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity,
//            pressing: { pressing in
//                withAnimation(.easeInOut(duration: 0.1)) {
//                    isPressed = pressing
//                }
//            },
//            perform: {}
//        )
//    }
//}
//import SwiftUI

struct CategoryCard: View {
    
    let icon: String
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment : .leading , spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.black)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.2),
                                        Color.black.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}
