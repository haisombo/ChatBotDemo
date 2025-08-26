//
//  FileAttachmentsView.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//
import SwiftUI
import UniformTypeIdentifiers
import Combine
import PhotosUI

struct FileAttachmentsView: View {
    let files: [AttachedFile]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(files) { file in
                FileItemView(file: file)
            }
        }
    }
}
struct FileItemView: View {
    let file: AttachedFile
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Handle file tap
            print("File tapped: \(file.name)")
        }) {
            HStack(spacing: 12) {
                // File Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(file.type.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: file.type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(file.type.color)
                }
                
                // File Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(file.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(file.type.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(file.formattedSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Download/Action Icon
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
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
struct ImageGridView: View {
    let images: [UIImage]
    let onImageTap: (UIImage) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: images.count == 1 ? [GridItem(.flexible())] : columns, spacing: 8) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                Button(action: { onImageTap(image) }) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: images.count == 1 ? 200 : 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
// MARK: - Image Viewer Sheet
//struct ImageViewerSheet: View {
//    let image: UIImage
//    @Environment(\.dismiss) var dismiss
//    @State private var scale: CGFloat = 1.0
//    @State private var lastScale: CGFloat = 1.0
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color.black.ignoresSafeArea()
//                
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .scaleEffect(scale)
//                    .gesture(
//                        MagnificationGesture()
//                            .onChanged { value in
//                                scale = lastScale * value
//                            }
//                            .onEnded { value in
//                                lastScale = scale
//                            }
//                    )
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                    .foregroundColor(.white)
//                }
//            }
//        }
//    }
//}
