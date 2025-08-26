//
//  LiquidGlassSuggestionsView.swift
//  ChatBotDemo
//
//  Complete Liquid Glass Suggestions View with iOS 16+ Blur Effects
//

import SwiftUI

// MARK: - Suggestion Data Model
struct SuggestionItem: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let title: String
    let prompt: String
}

// MARK: - Liquid Glass View Modifier
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var material: Material = .ultraThinMaterial
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // iOS 16+ Material Blur
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(material)
                    
                    // Glass overlay gradient for depth
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color.white
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Inner light reflection
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .padding(1)
                    
                    // Border highlight for glass edge
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, y: 1)
    }
}

// Extension for easy use
extension View {
    func liquidGlass(cornerRadius: CGFloat = 20, material: Material = .ultraThinMaterial) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, material: material))
    }
}

// MARK: - Individual Suggestion Pill
struct GlassSuggestionPill: View {
    let suggestion: SuggestionItem
    let action: () -> Void
    
    @State private var isPressed = false
    // Remove isHovered for iOS
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                action()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: suggestion.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary.opacity(0.8))
                
                Text(suggestion.prompt)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)

            }
          
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
//            .liquidGlass(cornerRadius: 18, material: .ultraThinMaterial)
//            .background(
//                // Subtle background for the entire suggestions area
//                Color.white
//                    .background(.ultraThinMaterial)
//                    .opacity(0.3)
//            )
//            .shadow(color: Color.black.opacity(0.1), radius: 5, y: 1)
//            .background(Color.white)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Main Liquid Glass Suggestions View
struct LiquidGlassSuggestionsView: View {
    @Binding var selectedPrompt: String
    @Binding var isVisible: Bool
    let onSelect: (String) -> Void
    
    // Customizable suggestions
    var suggestions: [SuggestionItem]
    
    // Animation state
    @State private var appearAnimation = false
    
    // Default suggestions if none provided
    static let defaultSuggestions = [
        SuggestionItem(icon: "lightbulb", title: "Ask about", prompt: "What can you help me with?"),
        SuggestionItem(icon: "doc.text", title: "Upload document", prompt: "I'd like to upload a document for analysis"),
        SuggestionItem(icon: "questionmark.circle", title: "Get help", prompt: "I need help with"),
        SuggestionItem(icon: "clock", title: "Recent topics", prompt: "Show me recent topics we discussed")
    ]
    
    init(selectedPrompt: Binding<String>,
         isVisible: Binding<Bool>,
         suggestions: [SuggestionItem]? = nil,
         onSelect: @escaping (String) -> Void) {
        self._selectedPrompt = selectedPrompt
        self._isVisible = isVisible
        self.suggestions = suggestions ?? Self.defaultSuggestions
        self.onSelect = onSelect
    }
    
    var body: some View {
        if isVisible {
            VStack(alignment: .leading, spacing: 0) {
                // Optional header
                HStack {
                    Image("ico_lamp_16")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text("Ask about")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : -10)
                
                // Scrollable suggestions
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, suggestion in
                            GlassSuggestionPill(suggestion: suggestion) {
                                handleSelection(suggestion)
                            }
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(index) * 0.05),
                                value: appearAnimation
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 44)
            }
            .padding(.vertical, 8)
            .background(
                // Subtle background for the entire suggestions area
                Color.white.opacity(0.01)
                    .background(.ultraThinMaterial)
                    .opacity(0.3)
            )
            .onAppear {
                withAnimation(.spring(response: 0.5)) {
                    appearAnimation = true
                }
            }
            .onDisappear {
                appearAnimation = false
            }
            .transition(
                .asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                )
            )
        }
    }
    
    private func handleSelection(_ suggestion: SuggestionItem) {
        // Haptic feedback on iOS
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
        
        withAnimation(.spring(response: 0.3)) {
            selectedPrompt = suggestion.prompt
            onSelect(suggestion.prompt)
            isVisible = false
        }
    }
}

// MARK: - Animated Suggestions View Variant
struct AnimatedLiquidGlassSuggestions: View {
    @Binding var selectedPrompt: String
    @Binding var isVisible: Bool
    let onSelect: (String) -> Void
    
    @State private var animateGradient = false
    
    let suggestions: [SuggestionItem]
    
    init(selectedPrompt: Binding<String>,
         isVisible: Binding<Bool>,
         suggestions: [SuggestionItem]? = nil,
         onSelect: @escaping (String) -> Void) {
        self._selectedPrompt = selectedPrompt
        self._isVisible = isVisible
        self.suggestions = suggestions ?? LiquidGlassSuggestionsView.defaultSuggestions
        self.onSelect = onSelect
    }
    
    var body: some View {
        if isVisible {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(suggestions) { suggestion in
                        Button(action: {
                            selectedPrompt = suggestion.prompt
                            onSelect(suggestion.prompt)
                            withAnimation {
                                isVisible = false
                            }
                        }) {
                            HStack(spacing: 8) {
//                                Image(systemName: suggestion.icon)
//                                    .font(.system(size: 14))
                                Text(suggestion.prompt)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                ZStack {
                                    // Animated gradient background
                                    LinearGradient(
                                        colors: animateGradient ?
                                            [Color.blue.opacity(0.1), Color.purple.opacity(0.1)] :
                                            [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                                        startPoint: animateGradient ? .topLeading : .bottomTrailing,
                                        endPoint: animateGradient ? .bottomTrailing : .topLeading
                                    )
                                    .blur(radius: 10)
                                    
                                    // Glass effect on top
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.ultraThinMaterial)
                                    
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 50)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
        }
    }
}

// MARK: - Usage Example
struct LiquidGlassSuggestionsExample: View {
    @State private var messageText = ""
    @State private var showSuggestions = true
    @State private var selectedPrompt = ""
    
    // Custom suggestions for specific context
    let customSuggestions = [
        SuggestionItem(icon: "creditcard", title: "What payment methods do you accept?", prompt: "What payment methods do you accept?"),
        SuggestionItem(icon: "truck", title: "Shipping info", prompt: "Tell me about shipping options"),
        SuggestionItem(icon: "return", title: "Returns", prompt: "What's your return policy?"),
        SuggestionItem(icon: "headphones", title: "Support", prompt: "I need customer support")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat area
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Welcome to WeBill365 Virtual Assistant")
                        .font(.title2)
                        .padding()
                    
                    Text("How can I help you today?")
                        .padding(.horizontal)
                }
            }
            
            Spacer()
            
            // Suggestions and Input Area
            VStack(spacing: 0) {
                // Liquid Glass Suggestions
                LiquidGlassSuggestionsView(
                    selectedPrompt: $selectedPrompt,
                    isVisible: $showSuggestions,
                    suggestions: customSuggestions,
                    onSelect: { prompt in
                        messageText = prompt
                        // Additional actions on selection
                        print("Selected: \(prompt)")
                    }
                )
                
                AdvancedInputBar(text: $messageText, viewModel: ChatViewModel(), onSend: {
                    messageText = ""
                } )
                
                
                
                // Input field (simplified)
//                HStack {
//                    TextField("Type a message...", text: $messageText)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    
//                    Button(action: {
//                        // Send action
//                        messageText = ""
//                        showSuggestions = true
//                    }) {
//                        Image(systemName: "arrow.up.circle.fill")
//                            .font(.system(size: 32))
//                            .foregroundColor(.blue)
//                    }
//                }
//                .padding()
//                .onChange(of: messageText) { newValue in
//                    showSuggestions = newValue.isEmpty
//                }
                
            }
          
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Preview
struct LiquidGlassSuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default suggestions
            LiquidGlassSuggestionsExample()
                .previewDisplayName("With Custom Suggestions")
            
            // Animated variant
            VStack {
                AnimatedLiquidGlassSuggestions(
                    selectedPrompt: .constant(""),
                    isVisible: .constant(true),
                    onSelect: { _ in }
                )
                Spacer()
            }
            .previewDisplayName("Animated Variant")
        }
    }
}
