//
//  AdvancedInputBar.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//

import SwiftUI
import PhotosUI
import Speech
import AVFoundation
import Combine

struct AdvancedInputBar: View {
    
    @Binding var text: String
    @ObservedObject var viewModel: ChatViewModel
    
    // Attachments
    @State private var attachedImages: [UIImage] = []
    @State private var attachedFiles: [AttachedFile] = []
    @State private var isRecording = false
    @State private var showImagePicker = false
    @State private var showDocumentPicker = false
    @State private var showCamera = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var textEditorHeight: CGFloat = 40
    @State private var showFullEditor = false
    @FocusState private var isFocused: Bool
    
    // IMPORTANT: Add sending state to prevent double sends and UI issues
    @State private var isSending = false
    @State private var isDisabled = false
    
    // Voice Recognition States
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var recordingTime: TimeInterval = 0
    @State private var recordingTimer: Timer?
    @State private var animateListening = false
    @State private var showVoiceError = false
    @State private var voiceErrorMessage = ""
    @State private var isTranscribing = false
    @State private var buttonPressed = false
    
    // Character count
    let maxCharacters: Int = 200
    let onSend: (() -> Void)?
    let maxTextHeight: CGFloat = 120
    let minTextHeight: CGFloat = 40
    @State private var height: CGFloat = 40

    // Computed properties
    private var isMultiline: Bool {
        textEditorHeight > minTextHeight || text.contains("\n")
    }
    
    private var characterCountText: String {
        "\(text.count)/\(maxCharacters)"
    }
    
    private var isNearLimit: Bool {
        text.count > Int(Double(maxCharacters) * 0.9)
    }
    
    // FIXED: Check sending state
    private var shouldShowSendButton: Bool {
        (!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !attachedImages.isEmpty ||
        !attachedFiles.isEmpty) && !isSending
    }
    
    private var hasAttachments: Bool {
        !attachedImages.isEmpty || !attachedFiles.isEmpty
    }
    
    // FIXED: Check if can interact
    private var canInteract: Bool {
        !isSending && !isDisabled
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced Attached Items Preview
            if hasAttachments {
                ScrollView(.horizontal, showsIndicators: false) {
                    EnhancedAttachedItemsPreview(
                        images: $attachedImages,
                        files: $attachedFiles,
                        onRemoveImage: removeImage,
                        onRemoveFile: removeFile
                    )
                }        .animation(.spring(), value: hasAttachments)

                .transition(.move(edge: .bottom).combined(with: .opacity))
                .disabled(isSending) // Disable during send
            }
            
//            VStack(alignment: .leading, spacing: 4) {
//                // Attachments preview (inline)
//                if hasAttachments {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        EnhancedAttachedItemsPreview(
//                            images: $attachedImages,
//                            files: $attachedFiles,
//                            onRemoveImage: removeImage,
//                            onRemoveFile: removeFile
//                        )
//                    }
//                    .frame(height: 60)
//                    .transition(.opacity)
//                }
//            }
            // Main Input Section
            if isRecording {
                enhancedVoiceRecordingView
            } else if isMultiline && !isRecording {
                // Multiline layout
                VStack(alignment: .leading, spacing: 4) {
                    expandableTextFieldWithCounterGroup
                    
                    HStack {
                        enhancedAttachmentButton
                        Spacer()
                        
                        HStack(spacing: 8) {
                            if !isSending { // Hide counter when sending
                                characterCountView
                            }
                            actionButton
                        }
                    }
                }
            } else {
                // Single line layout
                HStack(alignment: .center) {
                    if !isRecording {
                        enhancedAttachmentButton
                    }
                    
                    expandableTextFieldWithCounterGroup
                    
                    if !text.isEmpty && !isSending {
                        characterCountView
                    }
                    
                    if !isMultiline {
                        actionButton
                    }
                }
            }
        }
        .opacity(isDisabled ? 0.6 : 1.0) // Visual feedback when disabled
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isSending ? Color.gray.opacity(0.3) :
                    isRecording ? Color.blue :
                        hasAttachments ? Color.gray.opacity(0.5) :
                    Color.gray.opacity(0.3),
                    lineWidth: isRecording || hasAttachments ? 2 : 1
                )
                .animation(.easeInOut(duration: 0.3), value: isRecording)
                .animation(.easeInOut(duration: 0.3), value: hasAttachments)
                .animation(.easeInOut(duration: 0.3), value: isSending)
        )
        .padding()
        .background(Color.clear)
        .photosPicker(
            isPresented: $showImagePicker,
            selection: $selectedItems,
            maxSelectionCount: 10,
            matching: .images
        )
        .onChange(of: selectedItems) { items in
            if canInteract {
                loadSelectedImages(items)
            }
        }
        .fileImporter(
            isPresented: $showDocumentPicker,
            allowedContentTypes: [.pdf, .plainText, .item, .data],
            allowsMultipleSelection: true
        ) { result in
            if canInteract {
                handleFileSelection(result)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView { image in
                if let image = image, canInteract {
                    attachedImages.append(image)
                    print("📷 Camera captured image")
                }
                showCamera = false
            }
        }
        .onChange(of: text) { newValue in
            if newValue.count > maxCharacters {
                text = String(newValue.prefix(maxCharacters))
            }
        }
        .onAppear {
            speechRecognizer.requestAuthorization()
        }
    
        // Footer
        footerView
    }
    
    // MARK: - Enhanced Voice Recording View
    private var enhancedVoiceRecordingView: some View {
        HStack(spacing: 12) {
            // Animated microphone
            HStack(spacing: 8) {
                if text.isEmpty {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .scaleEffect(animateListening ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                            value: animateListening
                        )
                    
                    Text("Listening")
                        .foregroundColor(.blue)
                        .font(.system(size: 15, weight: .medium))
                    
                    ListeningDotsView()
                } else {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue.opacity(0.7))
                    
                    Text(text)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(.easeInOut(duration: 0.2), value: text)
                }
            }
            
            Spacer()
            
            // Timer and Stop button
            HStack(spacing: 12) {
                Text(formatTime(recordingTime))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    .monospacedDigit()
                
                Button(action: stopRecording) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var footerView: some View {
        HStack {
            Text("POWERED BY")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray.opacity(0.5))
            Text("WEBILL365")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
            Text("PRIVACY POLICY")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.blue)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Enhanced Attachment Button with File Support
    private var enhancedAttachmentButton: some View {
        Menu {
            Button(action: {
                if canInteract {
                    showImagePicker = true
                    print("📸 Opening photo library")
                }
            }) {
                Label("Photos", systemImage: "photo")
            }
            
            Button(action: {
                if canInteract {
                    showDocumentPicker = true
                    print("📁 Opening document picker")
                }
            }) {
                Label("Files", systemImage: "doc")
            }
            
//            Button(action: {
//                if canInteract {
//                    showCamera = true
//                    print("📷 Opening camera")
//                }
//            }) {
//                Label("Camera", systemImage: "camera")
//            }
            
//            Divider()
//            
//            Button(action: {
//                print("📍 Location - Not implemented")
//            }) {
//                Label("Location", systemImage: "location")
//            }
//            
//            Button(action: {
//                print("👤 Contact - Not implemented")
//            }) {
//                Label("Contact", systemImage: "person.crop.circle")
//            }
        } label: {
            ZStack {
                if isMultiline {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                }
                
                Image("ico_plus_16")
                    .font(.system(size: isMultiline ? 20 : 18, weight: .medium))
                    .foregroundColor(hasAttachments ? .gray : .gray)
                    .animation(.spring(response: 0.3), value: hasAttachments)
            }
            .padding(isMultiline ? 4 : 12)
        }
        .disabled(!canInteract) // Disable when sending
    }
    
    private var expandableTextFieldWithCounterGroup: some View {
        Group {
            if isMultiline {
                HStack(alignment: .bottom, spacing: 0) {
                    textEditorView
                }
            } else {
                HStack(alignment: .center, spacing: 0) {
                    textEditorView
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }

    private var textEditorView: some View {
        DynamicTextEditor(
            text: $text,
            height: $height,
            isFocused: _isFocused,
            minHeight: 40,
            maxHeight: 120,
            placeholder: isSending ? "" : "Start asking...", // No placeholder when sending
            isDisabled: isSending
        )
        .frame(height: height)
        .disabled(isSending)
        .animation(nil, value: text) // Disable text change animations
        .animation(nil, value: height) // Disable height change animations
    }

    private var characterCountView: some View {
        Text(characterCountText)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(isNearLimit ? .orange : .gray.opacity(0.6))
            .padding(.bottom, isMultiline ? 8 : 0)
    }
    
    private var actionButton: some View {
        Button(action: handleActionButton) {
            ZStack {
                // Ripple effects when recording
                if isRecording && animateListening {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: isMultiline ? 60 : 48, height: isMultiline ? 60 : 48)
                        .scaleEffect(animateListening ? 1.8 : 1.0)
                        .opacity(animateListening ? 0 : 0.6)
                        .animation(
                            .easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false),
                            value: animateListening
                        )
                }
                
                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isSending ?
                                [ Color.gray.opacity(0.8)] :
                                shouldShowSendButton && !isRecording ?
                                [Color.blue, Color.blue.opacity(0.8)] :
                                isRecording ?
                                [Color.red, Color.red.opacity(0.7)] :
                                [Color.blue.opacity(0.7), Color.purple.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isMultiline ? 44 : 36, height: isMultiline ? 44 : 36)
                    .scaleEffect(isRecording ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRecording)
                
                // Icon or Progress
                if isSending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.7)
                } else {
                    Image(systemName: buttonIcon)
                        .font(.system(size: isMultiline ? 18 : 16, weight: .semibold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isRecording ? 90 : 0))
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isRecording)
                }
            }
            .shadow(
                color: isSending ? Color.gray.opacity(0.2) :
                    isRecording ? Color.blue.opacity(0.4) :
                    shouldShowSendButton ? Color.blue.opacity(0.3) :
                    Color.purple.opacity(0.2),
                radius: isRecording ? 8 : 4,
                x: 0,
                y: 2
            )
            .scaleEffect(isRecording ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isRecording)
        }
        .disabled(!canInteract || (shouldShowSendButton && text.isEmpty && attachedImages.isEmpty && attachedFiles.isEmpty))
        .scaleEffect(buttonPressed ? 0.9 : 1.0)
        .padding(isMultiline ? 4 : 4)
        .animation(.spring(response: 0.3), value: shouldShowSendButton)
    }
    
    private var buttonIcon: String {
        if shouldShowSendButton && !isRecording {
            return "arrow.up"
        } else if isRecording {
            return "stop.fill"
        } else {
            return "mic.fill"
        }
    }
    
    // MARK: - FIXED Actions
    private func handleActionButton() {
        guard canInteract else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) {
            buttonPressed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) {
                buttonPressed = false
            }
        }
        
        if shouldShowSendButton && !isRecording {
            sendMessage()
        } else {
            toggleRecording()
        }
    }
    
    // MARK: - FIXED Send Message Function
    private func sendMessage() {
        guard shouldShowSendButton, !isSending else { return }
        
        // Store values BEFORE any UI updates
        let messageText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let messageImages = attachedImages
        let messageFiles = attachedFiles
        
        // IMMEDIATE UI updates (no animation)
        isSending = true
        text = ""
        attachedImages = []
        attachedFiles = []
        height = minTextHeight
        textEditorHeight = minTextHeight
        
        // Hide keyboard IMMEDIATELY
        isFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Send message ASYNC to prevent blocking
        Task {
            await viewModel.sendMessageAsync(
                messageText,
                images: messageImages.isEmpty ? nil : messageImages,
                files: messageFiles.isEmpty ? nil : messageFiles
            )
            
            await MainActor.run {
                isSending = false
                isDisabled = false
                onSend?()
            }
        }
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        guard canInteract else { return }
        
        print("🎤 Starting voice recording...")
        
        guard SFSpeechRecognizer(locale: Locale(identifier: "en-US")) != nil else {
            voiceErrorMessage = "Speech recognition is not available on this device"
            showVoiceError = true
            return
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    SFSpeechRecognizer.requestAuthorization { authStatus in
                        DispatchQueue.main.async {
                            switch authStatus {
                            case .authorized:
                                withAnimation(.spring()) {
                                    self.isRecording = true
                                    self.animateListening = true
                                    self.isTranscribing = true
                                }
                                
                                self.recordingTime = 0
                                self.recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                    self.recordingTime += 0.1
                                }
                                
                                self.speechRecognizer.startTranscribing { result in
                                    print("🎤 Received text: \(result)")
                                    
                                    if result.isEmpty && !self.text.isEmpty {
                                        print("⚠️ Ignoring empty result, keeping existing text: '\(self.text)'")
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if result.count <= self.maxCharacters {
                                                self.text = result
                                                print("✅ Text updated: '\(self.text)'")
                                            } else {
                                                self.text = String(result.prefix(self.maxCharacters))
                                                print("✅ Text truncated and updated: '\(self.text)'")
                                            }
                                        }
                                    }
                                } onError: { error in
                                    print("❌ Speech error: \(error)")
                                    self.voiceErrorMessage = error
                                    self.showVoiceError = true
                                    self.stopRecording()
                                }
                                
                            case .denied, .restricted, .notDetermined:
                                self.voiceErrorMessage = "Speech recognition access denied. Please enable it in Settings."
                                self.showVoiceError = true
                                
                            @unknown default:
                                self.voiceErrorMessage = "Unknown speech recognition authorization status."
                                self.showVoiceError = true
                            }
                        }
                    }
                } else {
                    self.voiceErrorMessage = "Microphone access is required for voice input. Please enable it in Settings."
                    self.showVoiceError = true
                }
            }
        }
    }
    
    private func stopRecording() {
        print("🛑 Stopping voice recording...")
        
        withAnimation(.spring()) {
            isRecording = false
            animateListening = false
            isTranscribing = false
        }
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        speechRecognizer.stopTranscribing()
        
        if !text.isEmpty {
            isFocused = true
            print("✅ Recording stopped with text: '\(text)'")
        }
    }
    
    private func removeImage(at index: Int) {
        guard index < attachedImages.count, canInteract else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            attachedImages.remove(at: index)
            print("🗑️ Removed image at index \(index)")
        }
    }
    
    private func removeFile(at id: UUID) {
        guard canInteract else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            attachedFiles.removeAll { $0.id == id }
            print("🗑️ Removed file with id \(id)")
        }
    }
    
    private func loadSelectedImages(_ items: [PhotosPickerItem]) {
        // Process images in background to prevent UI blocking
        Task.detached(priority: .background) {
            for item in items {
                // Load and compress image
                if let data = try? await item.loadTransferable(type: Data.self),
                   let originalImage = UIImage(data: data) {
                    
                    // Compress image BEFORE adding
                    let compressedImage = await compressImage(originalImage)
                    
                    await MainActor.run {
                        self.attachedImages.append(compressedImage)
                    }
                }
            }
            
            await MainActor.run {
                self.selectedItems = []
            }
        }
    }
    private func compressImage(_ image: UIImage) async -> UIImage {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                // Resize if too large
                let maxSize: CGFloat = 1024
                let size = image.size
                
                if size.width > maxSize || size.height > maxSize {
                    let ratio = min(maxSize / size.width, maxSize / size.height)
                    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
                    
                    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                    image.draw(in: CGRect(origin: .zero, size: newSize))
                    let resized = UIGraphicsGetImageFromCurrentImageContext() ?? image
                    UIGraphicsEndImageContext()
                    
                    // Compress to JPEG
                    if let data = resized.jpegData(compressionQuality: 0.7),
                       let compressed = UIImage(data: data) {
                        continuation.resume(returning: compressed)
                    } else {
                        continuation.resume(returning: resized)
                    }
                } else {
                    // Just compress
                    if let data = image.jpegData(compressionQuality: 0.7),
                       let compressed = UIImage(data: data) {
                        continuation.resume(returning: compressed)
                    } else {
                        continuation.resume(returning: image)
                    }
                }
            }
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            print("📁 Processing \(urls.count) selected files...")
            
            for url in urls {
                let gotAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if gotAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
                if let fileData = try? Data(contentsOf: url) {
                    let fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                    let fileSize = fileAttributes?[.size] as? Int64 ?? 0
                    
                    let file = AttachedFile(
                        name: url.lastPathComponent,
                        size: fileSize,
                        type: AttachedFile.getFileType(from: url.pathExtension),
                        data: fileData,
                        url: url,
                        uploadProgress: nil
                    )
                    
                    withAnimation(.spring()) {
                        attachedFiles.append(file)
                        print("✅ File attached: \(file.name) (\(file.formattedSize))")
                    }
                }
            }
            
        case .failure(let error):
            print("❌ File selection error: \(error.localizedDescription)")
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct EnhancedAttachedItemsPreview: View {
    @Binding var images: [UIImage]
    @Binding var files: [AttachedFile]
    let onRemoveImage: (Int) -> Void
    let onRemoveFile: (UUID) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                
                // Images
                ForEach(images.indices, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                            .clipped()
                        
                        Button(action: { onRemoveImage(index) }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding(4)
                    }
                }
                
                // Files
                ForEach(files) { file in
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 4) {
                            Image(systemName: file.type.icon)
                                .font(.system(size: 28))
                                .foregroundColor(file.type.color)
                            
                            Text(file.name)
                                .font(.caption2)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .frame(width: 70)
                            
                            Text(file.formattedSize)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(6)
                        .frame(width: 80, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(file.type.color.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        Button(action: { onRemoveFile(file.id) }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding(4)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Camera Picker View
struct CameraPickerView: UIViewControllerRepresentable {
    let onCapture: (UIImage?) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            parent.onCapture(image)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCapture(nil)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
// 2. OPTIMIZED SimpleFilePreview - Add this to your AdvancedInputBar.swift:
struct SimpleFilePreview: View {
    let file: AttachedFile
    let onRemove: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 2) {
                Image(systemName: file.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(file.type.color)
                
                Text(String(file.name.prefix(8)))
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
            )
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.6)))
            }
            .offset(x: 5, y: -5)
        }
    }
}
struct ListeningDotsView: View {
    @State private var animateDots = [false, false, false]
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 4, height: 4)
                    .scaleEffect(animateDots[index] ? 1.5 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animateDots[index]
                    )
            }
        }
        .onAppear {
            for index in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                    animateDots[index] = true
                }
            }
        }
    }
}



//struct AdvancedInputBar_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            // Background similar to your UI
//            LinearGradient(
//                colors: [
//                    Color(red: 0.96, green: 0.95, blue: 1.0),
//                    Color(red: 1.0, green: 0.98, blue: 0.98)
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//            
//            VStack {
//                Spacer()
//                
//                AdvancedInputBar(
//                    text: .constant(""), viewModel: viewModel,
//                    onSend: {
//                        print("Message sent!")
//                    }
//                )
//                
//            }
//        }
//    }
//}
struct AdvancedInputBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background similar to your UI
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.95, blue: 1.0),
                    Color(red: 1.0, green: 0.98, blue: 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Sample chat messages area (optional, for visual context)
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Sample message bubbles
                        Text("Sample conversation area")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                
                // The input bar
                AdvancedInputBar(
                    text: .constant(""),
                    viewModel: ChatViewModel(), // Create instance here
                    onSend: {
                        print("Message sent!")
                    }
                )
            }
        }
        .previewDisplayName("Default State")
        
        // Additional preview states
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.95, blue: 1.0),
                    Color(red: 1.0, green: 0.98, blue: 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                AdvancedInputBar(
                    text: .constant("Hello, how can you help me?"),
                    viewModel: ChatViewModel(),
                    onSend: {
                        print("Message sent!")
                    }
                )
            }
        }
        .previewDisplayName("With Text")
        
        // Preview with multiline text
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.95, blue: 1.0),
                    Color(red: 1.0, green: 0.98, blue: 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                AdvancedInputBar(
                    text: .constant("This is a longer message\nthat spans multiple lines"),
                    viewModel: ChatViewModel(),
                    onSend: {
                        print("Message sent!")
                    }
                )
            }
        }
        .previewDisplayName("Multiline Text")
    }
}

// Alternative: If you want a simpler preview with just one state
struct AdvancedInputBar_SimplePreview: PreviewProvider {
    @StateObject static var viewModel = ChatViewModel()
    @State static var previewText = ""
    
    static var previews: some View {
        VStack {
            Spacer()
            
            // Chat area placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    Text("Chat messages appear here")
                        .foregroundColor(.gray)
                )
            
            // Input bar
            AdvancedInputBar(
                text: $previewText,
                viewModel: viewModel,
                onSend: {
                    print("Sent: \(previewText)")
                    previewText = ""
                }
            )
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.95, blue: 1.0),
                    Color(red: 1.0, green: 0.98, blue: 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}
