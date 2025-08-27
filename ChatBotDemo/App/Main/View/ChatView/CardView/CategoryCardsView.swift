//
//  CategoryCardsView.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//
import SwiftUI

struct CategoryCardsView: View {
    
    @ObservedObject var viewModel   : ChatViewModel
    
    let categories = [
        ("wrench.and.screwdriver", "Technical Support"),
        ("dollarsign.circle", "Sales & Pricing")
    ]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(categories, id: \.1) { icon, title in
                CategoryCard(icon: icon, title: title) {
                    viewModel.selectCategory(title)
                }
            }
        }
        .padding(.horizontal, 4)
        HStack(spacing: 12) {
            ForEach(categories, id: \.1) { icon, title in
                CategoryCard(icon: icon, title: title) {
                    viewModel.selectCategory(title)
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
