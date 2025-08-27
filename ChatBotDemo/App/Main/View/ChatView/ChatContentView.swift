//
//  ChatContentView.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//
import SwiftUI

struct ChatContentView: View {
    
    @ObservedObject var viewModel       : ChatViewModel
    let showTranslation                 : Bool
    let selectedLanguage                : String
    @Namespace private var bottomID
    
    @State private var isAutoScrolling      = false
    @State private var shouldShowWelcome    = true
    @State private var visibleMessageIDs    = Set<UUID>()

    var body: some View {
        
        ScrollViewReader { proxy in
            ScrollView {
                // Welcome section
                if shouldShowWelcome && viewModel.messages.isEmpty {
                    
                    VStack(spacing: 16) {
                        WelcomeMessageView()
                            .padding(.top)
                        CategoryCardsView(viewModel: viewModel)
                    }
                    .padding()
                }
                
                // CRITICAL: Use ForEach without LazyVStack to prevent hang
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        // Use lightweight bubble for visible messages only
                        if visibleMessageIDs.contains(message.id) {
                            LightweightMessageBubble(
                                message: message,
                                showTranslation: showTranslation,
                                targetLanguage: selectedLanguage
                            )
                            .id(message.id)
                        } else {
                            // Placeholder for not-yet-visible messages
                            MessagePlaceholder(message: message)
                                .id(message.id)
                                .onAppear {
                                    visibleMessageIDs.insert(message.id)
                                }
                        }
                    }
                    
                    Color.clear
                        .frame(height: 1)
                        .id(bottomID)
                }

                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onReceive(
                      viewModel.$messages
                          .removeDuplicates()
                          .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            ) { messages in
                // Throttled scroll to prevent multiple calls
                if !isAutoScrolling && !messages.isEmpty {
                    isAutoScrolling = true
                    proxy.scrollTo(bottomID, anchor: .bottom)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isAutoScrolling = false
                    }
                }
            }
        }
    }
}

struct LightweightMessageBubble: View {
    let message: ChatMessage
    let showTranslation: Bool
    let targetLanguage: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {

            if message.isUser {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: .trailing, spacing: 4) {
                
                switch message.type {
                case .typing:
                    SimpleTypingIndicator()
                case .text, .mixed:
                    MessageContent(message: message)
                default:
                    MessageContent(message: message)
                }
                
                // Timestamp
                if !message.isTyping {
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            if !message.isUser {
                Spacer(minLength: 40)
            }
            

        }
    }
}


// Placeholder for messages not yet visible
struct MessagePlaceholder: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {

        }
    }
}


struct MessageContent: View {
    let message: ChatMessage
    @State private var loadImages = false
    @State private var loadFiles = false
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
            // Lazy load images
            if let images = message.images, !images.isEmpty {
                if loadImages {
                    AsyncMessageImagesGrid(images: images, isUser: message.isUser)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 200, height: 100)
                        .onAppear {
                            // Delay image loading to prevent hang
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                loadImages = true
                            }
                        }
                }
            }
            
            // Lazy load files
            if let files = message.attachedFiles, !files.isEmpty {
                if loadFiles {
                    VStack(spacing: 4) {
                        ForEach(files.prefix(3)) { file in
                            SimpleFileAttachment(file: file)
                        }
                    }
                } else {
                    Text("\(files.count) file(s)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                loadFiles = true
                            }
                        }
                }
            }
            
            if !message.content.isEmpty {
                if message.isUser {
                    // User messages - purple background with dark text
                    Text(message.content)
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor.label))  // Dark text for user
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(red: 0.85, green: 0.82, blue: 0.95))  // Light purple background
                        )
                   
                } else {
                    // Bot messages - no background, just black text
                    Text(message.content)
                        .font(.system(size: 15))
                        .foregroundColor(.black)  // Black text for bot
                        .padding(.horizontal, 4)  // Minimal padding
                        .textSelection(.enabled)  // Allow text selection
                }
            }
        }
    }
}


struct AsyncMessageImagesGrid: View {
    let images: [UIImage]
    let isUser: Bool
    @State private var thumbnails: [UIImage?] = []
    
    var body: some View {
        Group {
            if thumbnails.isEmpty {
                ProgressView()
                    .frame(width: 200, height: 100)
                    .onAppear {
                        loadThumbnailsAsync()
                    }
            } else {
                imageGrid
            }
        }
    }
    
    @ViewBuilder
    private var imageGrid: some View {
        if images.count == 1, let thumb = thumbnails.first, let image = thumb {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120) // grid size
                 .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                 .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(red: 0.75, green: 0.70, blue: 0.90), lineWidth: 2)  // More visible purple

                 )
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 5)], spacing: 5) {
                ForEach(0..<min(thumbnails.count, 3), id: \.self) { index in
                    if let thumb = thumbnails[index] {
                        Image(uiImage: thumb)
                            .resizable()
                            .scaledToFill()
//                            .frame(width: 60, height: 60)
                            .frame(width: 120, height: 120) // grid size
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))  // Added this
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color(red: 0.75, green: 0.70, blue: 0.90), lineWidth: 2)  // More visible purple

                            )
                    }
                }
                
                if images.count > 3 {
                    Text("+\(images.count - 3)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 40)
                }
            }
        }
    }
    
    private func loadThumbnailsAsync() {
        Task.detached(priority: .userInitiated) {
            var thumbs: [UIImage?] = []
            
            for image in images.prefix(3) {
                // Create small thumbnail
                let size = CGSize(width: 120, height: 120)
                let thumb = await Task.detached {
                    image.preparingThumbnail(of: size)
                }.value
                thumbs.append(thumb)
            }
            
            await MainActor.run {
                self.thumbnails = thumbs
            }
        }
    }
}

struct SimpleFileAttachment: View {
    let file: AttachedFile
    
    var body: some View {
        HStack(spacing: 12) {
            // File icon with background
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: file.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.red)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(Color(UIColor.label))
                
                Text(file.formattedSize)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .frame(width: 261, height: 74)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 0.85, green: 0.82, blue: 0.95))  // Light purple background
        )

    }
}

// 6. SIMPLE Typing Indicator (No complex animations)
struct SimpleTypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { _ in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
            }
        }
        .opacity(animating ? 1.0 : 0.5)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                animating = true
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)

    }
}
