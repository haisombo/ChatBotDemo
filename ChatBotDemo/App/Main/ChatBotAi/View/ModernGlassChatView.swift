//
//  ModernGlassChatView.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//


import SwiftUI
import AVFoundation
import Combine
import QuickLook

struct ModernGlassChatView: View {
    
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @State private var showTranslation = false
    @State private var selectedLanguage = "EN"
    @State private var isAnimating = false
    @State private var glowAnimation = false
    @State private var showSuggestions = true
    
    // Custom suggestions for specific context
    let customSuggestions = [
        SuggestionItem(icon: "creditcard", title: "Payment methods", prompt: "What payment methods do you accept?"),
        SuggestionItem(icon: "truck", title: "Shipping", prompt: "Tell me about shipping options"),
        SuggestionItem(icon: "return", title: "Returns", prompt: "What's your return policy?"),
        SuggestionItem(icon: "headphones", title: "Support", prompt: "I need customer support")
    ]
    
    var body: some View {
        ZStack {
            // Background
            backgroundView
            
            // Main Content
            mainContentView
        }
        
        .onChange(of: inputText) { newValue in
            // Show suggestions only when input is empty and at start of conversation
            showSuggestions = newValue.isEmpty && viewModel.messages.count <= 2
        }
    }
    
    // MARK: - Extracted Components
    private var backgroundView: some View {
        RadialGradientBackground()
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            headerSection
            chatSection
            inputSection
        }
    }
    
    private var headerSection: some View {
        GlassmorphicHeaderView(
            showTranslation: $showTranslation,
            selectedLanguage: $selectedLanguage
        )
    }
    
    private var chatSection: some View {
        
        ChatContentView(
            viewModel: viewModel,
            showTranslation: showTranslation,
            selectedLanguage: selectedLanguage
        )
    }
    
    private var inputSection: some View {
        VStack(spacing: 0) {
            // Liquid Glass Suggestions - only show when appropriate
            if showSuggestions && viewModel.messages.count <= 2 {
                LiquidGlassSuggestionsView(
                    selectedPrompt: .constant(""),
                    isVisible: $showSuggestions,
                    suggestions: customSuggestions,
                    onSelect: { prompt in
                        inputText = prompt
                        showSuggestions = false
                        print("Selected suggestion: \(prompt)")
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Advanced Input Bar with ViewModel
            AdvancedInputBar(
                text: $inputText,
                viewModel: viewModel,
                onSend: {
                    print("Message sent: \(inputText)")
                    showSuggestions = false
                }
            )
        }
    }
}

// MARK: - Dynamic Message Bubble (Enhanced with preview)
struct DynamicMessageBubble: View {
    let message: ChatMessage
    let showTranslation: Bool
    let targetLanguage: String
    
    @State private var showImageViewer = false
    @State private var selectedImage: UIImage?
    @State private var selectedImages: [UIImage] = []
    @State private var selectedImageIndex = 0
    @State private var showFilePreview = false
    @State private var selectedFile: AttachedFile?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Avatar for AI messages
            if !message.isUser {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
            }
            
            if message.isUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
          // the grop of the path of response in the chat
                Group {
                    switch message.type {
                    case .text, .mixed:
                        textMessageContent
                    case .image:
                        imageMessageContent
                    case .file:
                        fileMessageContent
                    case .voice:
                        voiceMessageContent
                    case .card:
                        cardMessageContent
                    case .options:
                        optionsMessageContent
                    case .typing:
                        typingIndicator
                    }
                }
                
                // Timestamp
                if !message.isTyping {
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer(minLength: 60)
            }
            
            // Avatar for user messages
            if message.isUser {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.orange, Color.pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
            }
        }
        .sheet(isPresented: $showImageViewer) {
            // Fixed: Check if selectedImages is not empty
            if !selectedImages.isEmpty {
                ImageGalleryViewer(
                    images: selectedImages,
                    selectedIndex: $selectedImageIndex
                )
            } else if let image = selectedImage {
                ImageViewerSheet(image: image)
            }
        }
        .sheet(isPresented: $showFilePreview) {
            if let file = selectedFile {
                FilePreviewSheet(file: file)
            }
        }
    }
    
    // MARK: - Message Type Views
    
    private var textMessageContent: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
            // Images if any - CLICKABLE
            if let images = message.images, !images.isEmpty {
                MessageImagesGrid(
                    images: images,
                    isUser: message.isUser
                )
                .onTapGesture {
                    selectedImages = images
                    selectedImageIndex = 0
                    showImageViewer = true
                }
            }
            
            // Files if any - CLICKABLE
            if let files = message.attachedFiles, !files.isEmpty {
                VStack(spacing: 4) {
                    ForEach(files) { file in
                        FileAttachmentView(file: file)
                            .onTapGesture {
                                selectedFile = file
                                showFilePreview = true
                            }
                    }
                }
            }
            
            // Text content
            if !message.content.isEmpty {
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.isUser ?
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
        }
    }
    
    private var imageMessageContent: some View {
        Group {
            if let images = message.images, !images.isEmpty {
                MessageImagesGrid(
                    images: images,
                    isUser: message.isUser
                )
                .onTapGesture {
                    selectedImages = images
                    selectedImageIndex = 0
                    showImageViewer = true
                }
            }
        }
    }
    
    private var fileMessageContent: some View {
        VStack(spacing: 4) {
            if let files = message.attachedFiles {
                ForEach(files) { file in
                    FileAttachmentView(file: file)
                        .onTapGesture {
                            selectedFile = file
                            showFilePreview = true
                        }
                }
            }
        }
    }
    
    private var voiceMessageContent: some View {
        HStack(spacing: 12) {
            Button(action: {
                // Play voice message
                print("Playing voice message")
            }) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            
            // Waveform visualization
            HStack(spacing: 2) {
                ForEach(0..<20, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue.opacity(0.5))
                        .frame(width: 2, height: CGFloat.random(in: 10...30))
                }
            }
            .frame(width: 120)
            
            Text(message.voiceDuration ?? "0:00")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    private var cardMessageContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = message.cardTitle {
                Text(title)
                    .font(.headline)
            }
            
            if let subtitle = message.cardSubtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let actions = message.cardActions {
                HStack(spacing: 8) {
                    ForEach(actions) { action in
                        Button(action: action.action) {
                            HStack {
                                if let icon = action.icon {
                                    Image(systemName: icon)
                                }
                                Text(action.title)
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5)
        )
    }
    
    private var optionsMessageContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !message.content.isEmpty {
                Text(message.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let options = message.options {
                VStack(spacing: 4) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            print("Selected option: \(option)")
                        }) {
                            Text(option)
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
    }
    
    private var typingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: UUID()
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.1))
        )
    }
}


// MARK: - Enhanced Image Viewer with Gallery Support
struct ImageGalleryViewer: View {
    let images: [UIImage]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                TabView(selection: $selectedIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = value
                                    }
                                    .onEnded { _ in
                                        withAnimation {
                                            scale = max(1, min(scale, 3))
                                        }
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        if scale > 1 {
                                            offset = value.translation
                                        }
                                    }
                                    .onEnded { _ in
                                        withAnimation {
                                            offset = .zero
                                        }
                                    }
                            )
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    scale = scale > 1 ? 1 : 2
                                    offset = .zero
                                }
                            }
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // Top bar with image counter
                VStack {
                    HStack {
                        Text("\(selectedIndex + 1) / \(images.count)")
                            .foregroundColor(.white)
                            .padding()
                        
                        Spacer()
                        
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    .background(Color.black.opacity(0.5))
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct FilePreviewSheet: View {
    let file: AttachedFile
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // File icon
                ZStack {
                    Circle()
                        .fill(file.type.color.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: file.type.icon)
                        .font(.system(size: 50))
                        .foregroundColor(file.type.color)
                }
                
                // File info
                VStack(spacing: 8) {
                    Text(file.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text(file.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(file.formattedSize)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: { downloadFile(file) }) {
                        Label("Download", systemImage: "arrow.down.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: { shareFile(file) }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func downloadFile(_ file: AttachedFile) {
        print("Downloading file: \(file.name)")
        // Implement download logic
    }
    
    private func shareFile(_ file: AttachedFile) {
        print("Sharing file: \(file.name)")
        // Implement share logic
    }
}

// MARK: - File Attachment View (Clickable)
struct FileAttachmentView: View {
    let file: AttachedFile
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(file.type.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: file.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(file.type.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                
                Text(file.formattedSize)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3)
        )
    }
}


// MARK: - Single Image Viewer (RESTORED)
struct ImageViewerSheet: View {
    let image: UIImage
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { value in
                                lastScale = scale
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation
                            }
                            .onEnded { _ in
                                withAnimation {
                                    offset = .zero
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            if scale > 1 {
                                scale = 1
                                lastScale = 1
                                offset = .zero
                            } else {
                                scale = 2
                                lastScale = 2
                            }
                        }
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { saveImage(image) }) {
                            Label("Save Image", systemImage: "square.and.arrow.down")
                        }
                        
                        Button(action: { shareImage(image) }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private func saveImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    private func shareImage(_ image: UIImage) {
        let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(av, animated: true)
        }
    }
}
// MARK: - Preview with Sample ViewModel
struct ModernGlassChatView_Previews: PreviewProvider {
    static var previews: some View {
        ModernGlassChatView()
    }
}
