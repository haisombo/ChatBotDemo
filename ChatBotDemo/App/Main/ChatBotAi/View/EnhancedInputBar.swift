////
////  EnhancedInputBar.swift
////  ChatBotDemo
////
////  Created by Sombo Mobile R&D on 22/8/25.
////
//
//import SwiftUI
//import PhotosUI
//import Speech
//import AVFoundation
//
//struct EnhancedInputBar: View {
//    
//    @Binding var text: String
//    @ObservedObject var viewModel: ChatViewModel
//    @State private var attachedImages: [UIImage] = []
//    @State private var attachedFiles: [AttachedFile] = []
//    @State private var showImagePicker = false
//    @State private var showDocumentPicker = false
//    @State private var selectedItems: [PhotosPickerItem] = []
//    @State private var height: CGFloat = 40
//    @FocusState private var isFocused: Bool
//    
//    let maxCharacters = 5000
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Attached Items Preview
//            if !attachedImages.isEmpty || !attachedFiles.isEmpty {
//                AttachedItemsPreview(
//                    images: $attachedImages,
//                    files: $attachedFiles
//                )
//            }
//            
//            // Input Area
//            HStack(alignment: .bottom, spacing: 8) {
//                // Attachment Menu
//                Menu {
//                    Button(action: { showImagePicker = true }) {
//                        Label("Photos", systemImage: "photo")
//                    }
//                    
//                    Button(action: { showDocumentPicker = true }) {
//                        Label("Files", systemImage: "doc")
//                    }
//                    
//                    Button(action: { /* Camera action */ }) {
//                        Label("Camera", systemImage: "camera")
//                    }
//                } label: {
//                    Image(systemName: "plus.circle.fill")
//                        .font(.system(size: 28))
//                        .foregroundColor(.blue)
//                }
//                
//                // Text Input
//                DynamicTextEditor(
//                    text: $text,
//                    height: $height,
//                    isFocused: _isFocused,
//                    minHeight: 40,
//                    maxHeight: 120,
//                    placeholder: "Message"
//                )
//                .frame(height: height)
//                .padding(.horizontal, 12)
//                .background(
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(Color.gray.opacity(0.1))
//                )
//                
//                // Send Button
//                Button(action: sendMessage) {
//                    Image(systemName: shouldShowSendButton ? "arrow.up.circle.fill" : "mic.circle.fill")
//                        .font(.system(size: 28))
//                        .foregroundColor(shouldShowSendButton ? .blue : .gray)
//                }
//                .disabled(!shouldShowSendButton)
//            }
//            .padding()
//        }
//        .photosPicker(
//            isPresented: $showImagePicker,
//            selection: $selectedItems,
//            maxSelectionCount: 10,
//            matching: .images
//        )
//        .onChange(of: selectedItems) { items in
//            loadSelectedImages(items)
//        }
//        .fileImporter(
//            isPresented: $showDocumentPicker,
//            allowedContentTypes: [.pdf, .plainText, .item],
//            allowsMultipleSelection: true
//        ) { result in
//            handleFileSelection(result)
//        }
//    }
//    
//    private var shouldShowSendButton: Bool {
//        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
//        !attachedImages.isEmpty ||
//        !attachedFiles.isEmpty
//    }
//    
//    private func sendMessage() {
//        guard shouldShowSendButton else { return }
//        
//        viewModel.sendMessage(
//            text: text,
//            images: attachedImages.isEmpty ? nil : attachedImages,
//            files: attachedFiles.isEmpty ? nil : attachedFiles
//        )
//        
//        // Clear inputs
//        text = ""
//        attachedImages = []
//        attachedFiles = []
//        isFocused = false
//    }
//    
//    private func loadSelectedImages(_ items: [PhotosPickerItem]) {
//        for item in items {
//            Task {
//                if let data = try? await item.loadTransferable(type: Data.self),
//                   let uiImage = UIImage(data: data) {
//                    await MainActor.run {
//                        attachedImages.append(uiImage)
//                    }
//                }
//            }
//        }
//        selectedItems = []
//    }
//    
//    private func handleFileSelection(_ result: Result<[URL], Error>) {
//        switch result {
//        case .success(let urls):
//            for url in urls {
//                if let fileData = try? Data(contentsOf: url) {
//                    let fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path)
//                    let fileSize = fileAttributes?[.size] as? Int64 ?? 0
//                    
//                    let file = AttachedFile(
//                        name: url.lastPathComponent,
//                        size: fileSize,
//                        type: AttachedFile.getFileType(from: url.pathExtension),
//                        data: fileData,
//                        url: url
//                    )
//                    attachedFiles.append(file)
//                }
//            }
//        case .failure(let error):
//            print("File selection error: \(error)")
//        }
//    }
//}
//
//struct AttachedItemsPreview: View {
//    @Binding var images: [UIImage]
//    @Binding var files: [AttachedFile]
//    
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 8) {
//                // Images
//                ForEach(Array(images.enumerated()), id: \.offset) { index, image in
//                    AttachedImageItem(image: image) {
//                        images.remove(at: index)
//                    }
//                }
//                
//                // Files
//                ForEach(files) { file in
//                    AttachedFileItem(file: file) {
//                        files.removeAll { $0.id == file.id }
//                    }
//                }
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 8)
//        }
//        .background(Color.gray.opacity(0.05))
//    }
//}
//
//struct AttachedImageItem: View {
//    let image: UIImage
//    let onRemove: () -> Void
//    
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            Image(uiImage: image)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 80, height: 80)
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//            
//            Button(action: onRemove) {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 20))
//                    .foregroundColor(.white)
//                    .background(Circle().fill(Color.black.opacity(0.6)))
//            }
//            .offset(x: 5, y: -5)
//        }
//    }
//}
//
//struct AttachedFileItem: View {
//    let file: AttachedFile
//    let onRemove: () -> Void
//    
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            VStack(spacing: 4) {
//                Image(systemName: file.type.icon)
//                    .font(.system(size: 30))
//                    .foregroundColor(file.type.color)
//                
//                Text(file.name)
//                    .font(.caption2)
//                    .lineLimit(1)
//                    .truncationMode(.middle)
//                    .frame(width: 70)
//                
//                Text(file.formattedSize)
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//            }
//            .padding(8)
//            .frame(width: 80, height: 80)
//            .background(
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(Color.gray.opacity(0.1))
//            )
//            
//            Button(action: onRemove) {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 20))
//                    .foregroundColor(.white)
//                    .background(Circle().fill(Color.black.opacity(0.6)))
//            }
//            .offset(x: 5, y: -5)
//        }
//    }
//}
