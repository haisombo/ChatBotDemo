//
//  GlassmorphicHeaderView.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//

import SwiftUI

struct GlassmorphicHeaderView: View {
    
    @Binding var showTranslation    : Bool
    @Binding var selectedLanguage   : String
    @State private var showLanguagePicker = false
    
    var body: some View {
        HStack {
            // Logo with Glow Effect
            ZStack {
                Circle()
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image("ico_webill365")
                            .resizable()
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("WeBill365 Virtual Assistant")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
            }
            
            Spacer()
            // Close Buttond
            Button(action: {
                //dismiss
            }) {
                Image("ico_close_16")
                    .frame(width: 32, height: 32)
            }
        }
        .padding()
    }
}


