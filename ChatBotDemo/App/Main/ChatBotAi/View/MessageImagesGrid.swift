//
//  MessageImagesGrid.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//
import SwiftUI

struct MessageImagesGrid: View {
    
    let images: [UIImage]
    let isUser: Bool
    
    // Cache thumbnails for performance
    @State private var thumbnails: [UIImage] = []
    @State private var isLoadingThumbnails = true
    
    var body: some View {
        VStack(spacing: 8) {
            if isLoadingThumbnails {
                // Show placeholder while loading
                ProgressView()
                    .frame(width: 250, height: 150)
                    .onAppear {
                        loadThumbnails()
                    }
            } else {
                imageContent
            }
        }
        .padding(.horizontal, isUser ? 0 : 8)
    }
    
    @ViewBuilder
    private var imageContent: some View {
        if thumbnails.count == 1, let thumbnail = thumbnails.first {
            // Single image
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 250, maxHeight: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        } else if thumbnails.count == 2 {
            // Two images side by side
            HStack(spacing: 4) {
                ForEach(0..<2, id: \.self) { index in
                    if index < thumbnails.count {
                        Image(uiImage: thumbnails[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        } else if !thumbnails.isEmpty {
            // Grid for 3+ images - using more efficient layout
            let columns = [
                GridItem(.fixed(80), spacing: 4),
                GridItem(.fixed(80), spacing: 4),
                GridItem(.fixed(80), spacing: 4)
            ]
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(thumbnails.prefix(9).enumerated()), id: \.offset) { index, thumbnail in
                    ZStack {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        // Show "+X" for remaining images
                        if index == 8 && images.count > 9 {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 80, height: 80)
                            
                            Text("+\(images.count - 9)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(width: 248) // Fixed width for consistent layout
        }
    }
    
    private func loadThumbnails() {
        // Load thumbnails asynchronously to prevent UI blocking
        Task {
            let generatedThumbnails = await generateThumbnails()
            await MainActor.run {
                self.thumbnails = generatedThumbnails
                self.isLoadingThumbnails = false
            }
        }
    }
    
    private func generateThumbnails() async -> [UIImage] {
        var result: [UIImage] = []
        
        for (index, image) in images.prefix(9).enumerated() {
            // Determine appropriate size based on layout
            let targetSize: CGSize
            if images.count == 1 {
                targetSize = CGSize(width: 500, height: 500) // Larger for single image
            } else if images.count == 2 {
                targetSize = CGSize(width: 240, height: 240) // Medium for two images
            } else {
                targetSize = CGSize(width: 160, height: 160) // Smaller for grid
            }
            
            if let thumbnail = await createThumbnail(from: image, targetSize: targetSize) {
                result.append(thumbnail)
            } else {
                result.append(image) // Fallback to original if thumbnail fails
            }
        }
        
        return result
    }
    
    private func createThumbnail(from image: UIImage, targetSize: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let thumbnail = image.preparingThumbnail(of: targetSize) ??
                               self.resizeImage(image, targetSize: targetSize)
                continuation.resume(returning: thumbnail)
            }
        }
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Use the smaller ratio to maintain aspect ratio
        let ratio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Use newer rendering API for better performance
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1 // Use 1 for thumbnails to save memory
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}


//struct MessageImagesGrid: View {
//    
//    let images: [UIImage]
//    let isUser: Bool // Add this parameter to replace the message property
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            if images.count == 1 {
//                // Single image
//                Image(uiImage: images[0])
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(maxWidth: 250, maxHeight: 250)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//            } else if images.count == 2 {
//                // Two images side by side
//                HStack(spacing: 4) {
//                    ForEach(0..<2) { index in
//                        Image(uiImage: images[index])
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 120, height: 120)
//                            .clipShape(RoundedRectangle(cornerRadius: 8))
//                    }
//                }
//            } else {
//                // Grid for 3+ images
//                LazyVGrid(columns: [GridItem(.fixed(80)), GridItem(.fixed(80)), GridItem(.fixed(80))], spacing: 4) {
//                    ForEach(Array(images.prefix(9).enumerated()), id: \.offset) { index, image in
//                        ZStack {
//                            Image(uiImage: image)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 80, height: 80)
//                                .clipShape(RoundedRectangle(cornerRadius: 6))
//                            
//                            // Show "+X" for remaining images
//                            if index == 8 && images.count > 9 {
//                                RoundedRectangle(cornerRadius: 6)
//                                    .fill(Color.black.opacity(0.6))
//                                Text("+\(images.count - 9)")
//                                    .font(.system(size: 16, weight: .bold))
//                                    .foregroundColor(.white)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .padding(.horizontal, isUser ? 0 : 8)
//    }
//}
