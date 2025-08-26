//
//  ChatViewModel.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//
import Foundation
import Combine
import PhotosUI
import SwiftUI

class ChatViewModel: ObservableObject {
    
    // Published properties
    @Published var messages: [ChatMessage] = []
    @Published var messagesNew: [ChatMessageNew] = []
    @Published var selectedCategory: String? = nil
    @Published var showQuickActions = true
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentTypingMessage: ChatMessage?
    
    // Voice recording
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    
    // File upload progress
    @Published var uploadProgress: Double = 0
    @Published var isUploading = false
    
    // Quick actions
    @Published var quickActions = [
        "View and download invoices",
        "Update payment methods",
        "Manage subscriptions and plans",
        "Process refunds and credits"
    ]
    
    // Categories
    let categories = [
        "Billing & Payments",
        "Technical Support",
        "Account Management",
        "Product Information",
        "Shipping & Delivery",
        "Returns & Refunds"
    ]
    
    private var cancellables = Set<AnyCancellable>()
    private var typingTimer: Timer?
    
    init() {
//        loadInitialMessages()
        loadSampleMessages()
    }
    
    // MARK: - Message Loading
    private func loadSampleMessages() {
        messagesNew = [
            ChatMessageNew(
                content: "What payment methods do you accept?",
                isUser: true,
                isRead: true
            ),
            ChatMessageNew(
                content: "We accept various payment methods including credit cards, debit cards, digital wallets, and bank transfers. Would you like specific details about any of these options?",
                isUser: false,
                isRead: true
            ),
            ChatMessageNew(
                content: "Could you help check on this?\nThe error occurred because Radix UI's SelectItem component cannot accept empty strings as values. This is a validation rule to prevent confusion between",
                isUser: true,
                isRead: true
            )
        ]
    }
    
//    private func loadInitialMessages() {
//        // Welcome message
//        let welcomeMessage = ChatMessage(
//            content: "Hello! I'm your AI-powered assistant. I can help you with text, images, documents, and more. Choose an option below or ask me anything!",
//            isUser: false,
//            type: .text
//        )
//        messages.append(welcomeMessage)
//        
//        // Show initial options
//        let optionsMessage = ChatMessage(
//            content: "What can I help you with today?",
//            isUser: false,
//            type: .options,
//            options: [
//                "📄 Upload a document",
//                "🖼️ Share an image",
//                "💳 Billing & Payments",
//                "🔧 Technical Support",
//                "📦 Track my order",
//                "💬 Chat with support"
//            ]
//        )
//        messages.append(optionsMessage)
//    }
    
    // MARK: - Send Message with Attachments
    func sendMessage(
        _ text: String,
        images: [UIImage]? = nil,
        files: [AttachedFile]? = nil
    ) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              images != nil ||
              files != nil else { return }
        
        // Determine message type
        var messageType: MessageType = .text
        if images != nil && files != nil {
            messageType = .mixed
        } else if images != nil {
            messageType = .image
        } else if files != nil {
            messageType = .file
        }
        
        // Create user message
        let userMessage = ChatMessage(
            content: text,
            isUser: true,
            type: messageType,
            images: images,
            attachedFiles: files
        )
        
        messages.append(userMessage)
        
        // Show typing indicator
        showTypingIndicator()
        
        // Simulate bot response
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.hideTypingIndicator()
            self?.generateBotResponse(for: userMessage)
        }
    }
    
    // MARK: - Bot Response Generation
    private func generateBotResponse(for userMessage: ChatMessage) {
        var responseContent = ""
        var responseType: MessageType = .text
        
        // Context-aware response based on attachments
        if let images = userMessage.images, !images.isEmpty {
            responseContent = "I can see you've uploaded \(images.count) image(s). "
            
            // Simulate image analysis
            responseContent += "Based on my analysis:\n\n"
            responseContent += "📸 **Image Analysis Results:**\n"
            responseContent += "• The images appear to contain relevant information\n"
            responseContent += "• I can help you process, edit, or answer questions about these images\n"
            responseContent += "• Would you like me to extract text, identify objects, or perform any specific analysis?\n"
            
            if !userMessage.content.isEmpty {
                responseContent += "\n**Your question:** \"\(userMessage.content)\"\n"
                responseContent += "Let me address this based on the uploaded images..."
            }
        }
        
        if let files = userMessage.attachedFiles, !files.isEmpty {
            responseContent += "I've received \(files.count) file(s):\n\n"
            
            for file in files {
                responseContent += "📎 **\(file.name)**\n"
                responseContent += "   • Type: \(file.type.rawValue)\n"
                responseContent += "   • Size: \(file.formattedSize)\n\n"
            }
            
            responseContent += "I can help you:\n"
            responseContent += "• Extract and summarize content\n"
            responseContent += "• Answer questions about the documents\n"
            responseContent += "• Convert to different formats\n"
            responseContent += "• Analyze and provide insights\n"
        }
        
        // Handle text-only messages
        if userMessage.type == .text {
            responseContent = generateTextResponse(for: userMessage.content)
        }
        
        // Add contextual response
        if responseContent.isEmpty {
            responseContent = "I've received your message. How can I assist you with this?"
        }
        
        // Create bot response
        let botMessage = ChatMessage(
            content: responseContent,
            isUser: false,
            type: responseType
        )
        
        messages.append(botMessage)
        
        // Sometimes add a card or options
        if Bool.random() {
            addContextualFollowUp(for: userMessage)
        }
    }
    
    // MARK: - Text Response Generation
    private func generateTextResponse(for text: String) -> String {
        let lowercasedText = text.lowercased()
        
        // Payment-related responses
        if lowercasedText.contains("payment") || lowercasedText.contains("pay") {
            return """
            💳 **Payment Information:**
            
            We accept the following payment methods:
            • Credit/Debit Cards (Visa, MasterCard, Amex, Discover)
            • Digital Wallets (PayPal, Apple Pay, Google Pay)
            • Bank Transfers (ACH, Wire)
            • Cryptocurrency (Bitcoin, Ethereum)
            
            All transactions are secured with 256-bit SSL encryption.
            
            Would you like to update your payment method or learn more about our payment security?
            """
        }
        
        // Billing-related responses
        if lowercasedText.contains("billing") || lowercasedText.contains("invoice") {
            return """
            📊 **Billing Support:**
            
            I can help you with:
            • Viewing recent invoices
            • Downloading billing statements
            • Understanding charges
            • Setting up auto-pay
            • Updating billing information
            
            What specific billing information do you need?
            """
        }
        
        // Default intelligent response
        return """
        I understand you're asking about: "\(text)"
        
        Let me help you with that. Based on your query, I can:
        • Provide detailed information
        • Guide you through the process
        • Connect you with specialized support if needed
        
        Please let me know if you need any specific assistance or have additional questions.
        """
    }
    
    // MARK: - Contextual Follow-ups (FIXED)
    private func addContextualFollowUp(for userMessage: ChatMessage) {
        if userMessage.content.lowercased().contains("payment") {
            // Create a card message with cardActions properly set
            var cardMessage = ChatMessage(
                content: "",
                isUser: false,
                type: .card,
                cardTitle: "Recent Payment Activity",
                cardSubtitle: "Last payment: $125.00 on Dec 15, 2024"
            )
            
            // Set cardActions after creation
            cardMessage.cardActions = [
                CardAction(title: "View Details", icon: "eye") {
                    print("View payment details")
                },
                CardAction(title: "Download Receipt", icon: "arrow.down.doc") {
                    print("Download receipt")
                }
            ]
            
            messages.append(cardMessage)
        }
        
        // Add quick reply options
        let quickReplies = ChatMessage(
            content: "Related topics you might be interested in:",
            isUser: false,
            type: .options,
            options: [
                "Show me my recent transactions",
                "Update payment method",
                "Set up autopay",
                "Contact billing support"
            ]
        )
        messages.append(quickReplies)
    }
    
    // MARK: - Typing Indicator
    private func showTypingIndicator() {
        currentTypingMessage = ChatMessage(
            content: "",
            isUser: false,
            type: .typing,
            isTyping: true
        )
        
        if let typingMessage = currentTypingMessage {
            messages.append(typingMessage)
        }
    }
    
    private func hideTypingIndicator() {
        if let typingMessage = currentTypingMessage {
            messages.removeAll { $0.id == typingMessage.id }
            currentTypingMessage = nil
        }
    }
    
    // MARK: - Voice Recording
    func toggleRecording() {
        isRecording.toggle()
        
        if isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    private func startRecording() {
        recordingDuration = 0
        
        // Simulate recording duration update
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, self.isRecording else {
                timer.invalidate()
                return
            }
            self.recordingDuration += 0.1
        }
    }
    
    private func stopRecording() {
        // Create voice message
        let duration = formatDuration(recordingDuration)
        let voiceMessage = ChatMessage(
            content: "Voice message",
            isUser: true,
            type: .voice,
            voiceDuration: duration
        )
        messages.append(voiceMessage)
        
        // Reset
        recordingDuration = 0
        
        // Generate response
        showTypingIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.hideTypingIndicator()
            
            let response = ChatMessage(
                content: "I've received your voice message (\(duration)). Voice transcription: 'Your voice message content would appear here.'",
                isUser: false
            )
            self?.messages.append(response)
        }
    }
    
    // MARK: - File Upload
    func uploadFiles(_ urls: [URL]) {
        isUploading = true
        uploadProgress = 0
        
        var attachedFiles: [AttachedFile] = []
        
        for url in urls {
            if let fileData = try? Data(contentsOf: url) {
                let fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                let fileSize = fileAttributes?[.size] as? Int64 ?? 0
                
                let file = AttachedFile(
                    name: url.lastPathComponent,
                    size: fileSize,
                    type: AttachedFile.getFileType(from: url.pathExtension),
                    data: fileData,
                    url: url,
                    uploadProgress: 0
                )
                attachedFiles.append(file)
            }
        }
        
        // Simulate upload progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.uploadProgress += 0.1
            
            if self.uploadProgress >= 1.0 {
                timer.invalidate()
                self.isUploading = false
                
                // Send message with files
                self.sendMessage("Here are the files I'd like to share", files: attachedFiles)
            }
        }
    }
    
    // MARK: - Category Selection
    func selectCategory(_ category: String) {
        selectedCategory = category
        sendMessage("I need help with \(category)")
        
        // Add category-specific quick actions
        updateQuickActionsForCategory(category)
    }
    
    private func updateQuickActionsForCategory(_ category: String) {
        switch category {
        case "Billing & Payments":
            quickActions = [
                "View invoices",
                "Update payment method",
                "Check payment history",
                "Request refund"
            ]
        case "Technical Support":
            quickActions = [
                "Report a bug",
                "Connection issues",
                "Account access problem",
                "Feature not working"
            ]
        case "Shipping & Delivery":
            quickActions = [
                "Track my order",
                "Change delivery address",
                "Delivery options",
                "Missing package"
            ]
        default:
            quickActions = [
                "General inquiry",
                "Talk to human agent",
                "View documentation",
                "Submit feedback"
            ]
        }
    }
    
    // MARK: - Quick Action Handler
    func handleQuickAction(_ action: String) {
        sendMessage(action)
        showQuickActions = false
    }
    
    // MARK: - Edit Message
    func editMessage(_ messageId: UUID, newContent: String) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].content = newContent
            messages[index].isEdited = true
            messages[index].editedAt = Date()
        }
    }
    
    // MARK: - Delete Message
    func deleteMessage(_ messageId: UUID) {
        messages.removeAll { $0.id == messageId }
    }
    
    // MARK: - Mark as Read
    func markAsRead(_ messageId: UUID) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].isRead = true
        }
    }
    
    // MARK: - Clear Chat
    func clearChat() {
        messages.removeAll()
//        loadInitialMessages()
    }
    
    // MARK: - Helper Functions
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    @MainActor
    func sendMessageAsync(_ text: String, images: [UIImage]? = nil, files: [AttachedFile]? = nil) async {
        // Create message immediately
        let userMessage = ChatMessage(
            content: text,
            isUser: true,
            type: determineMessageType(text: text, images: images, files: files),
            images: images,
            attachedFiles: files
        )
        
        messages.append(userMessage)
        
        // Add typing indicator after small delay
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        let typingMessage = ChatMessage(
            content: "",
            isUser: false,
            type: .typing,
            isTyping: true
        )
        messages.append(typingMessage)
        
        // Simulate AI response
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        messages.removeAll { $0.isTyping }
        
        // Generate contextual response based on message content
        let responseText = generateContextualResponse(
            text: text,
            hasImages: images != nil,
            imageCount: images?.count ?? 0,
            hasFiles: files != nil,
            fileCount: files?.count ?? 0
        )
        
        let aiMessage = ChatMessage(
            content: responseText,
            isUser: false,
            type: .text
        )
        messages.append(aiMessage)
    }

    // Helper function to generate varied responses
    private func generateContextualResponse(
        text: String,
        hasImages: Bool,
        imageCount: Int,
        hasFiles: Bool,
        fileCount: Int
    ) -> String {
        
        // If message has attachments
        if hasImages || hasFiles {
            let responses = [
                "I received your message with \(imageCount) image\(imageCount == 1 ? "" : "s") and \(fileCount) file\(fileCount == 1 ? "" : "s"). How can I help you?",
                "I can see the \(imageCount > 0 ? "image\(imageCount == 1 ? "" : "s")" : "file\(fileCount == 1 ? "" : "s")") you've shared. What would you like me to do with \(imageCount + fileCount == 1 ? "it" : "them")?",
                "Thanks for sharing \(imageCount + fileCount == 1 ? "this" : "these"). How can I assist you with \(imageCount + fileCount == 1 ? "it" : "them")?",
                "I've received your attachment\(imageCount + fileCount == 1 ? "" : "s"). Please let me know what you need help with.",
                "Got \(imageCount + fileCount == 1 ? "it" : "them")! What would you like to know?"
            ]
            return responses.randomElement() ?? responses[0]
        }
        
        // Check for specific keywords and respond accordingly
        let lowercasedText = text.lowercased()
        
        if lowercasedText.contains("payment") || lowercasedText.contains("pay") {
            let responses = [
                "We accept major credit cards, PayPal, and bank transfers. Which payment method would you prefer?",
                "You can pay using Visa, MasterCard, Amex, PayPal, or direct bank transfer. All transactions are secure.",
                "Our payment options include credit/debit cards and digital wallets. Would you like to update your payment method?",
                "I can help you with payment methods. We accept cards, PayPal, and bank transfers. What specific information do you need?"
            ]
            return responses.randomElement() ?? responses[0]
        }
        
        if lowercasedText.contains("billing") || lowercasedText.contains("invoice") {
            let responses = [
                "I can assist with all billing matters. Would you like to view invoices, update payment methods, or check your billing history?",
                "For billing inquiries, I can help you access invoices, manage subscriptions, or resolve billing issues. What do you need?",
                "I'll help with your billing concern. Are you looking to download an invoice or update billing information?",
                "Billing support is available. Do you need help with invoices, payment methods, or subscription management?"
            ]
            return responses.randomElement() ?? responses[0]
        }
        
        if lowercasedText.contains("help") || lowercasedText.contains("assist") {
            let responses = [
                "I'm here to help! Could you provide more details about what you need assistance with?",
                "I'll be happy to assist you. What specific issue or question can I help you with?",
                "Sure, I can help. Please describe what you're looking for or what problem you're experiencing.",
                "I'm ready to assist. What would you like help with today?"
            ]
            return responses.randomElement() ?? responses[0]
        }
        
        if lowercasedText.contains("hello") || lowercasedText.contains("hi") {
            let responses = [
                "Hello! How can I assist you today?",
                "Hi there! What can I help you with?",
                "Welcome! How may I help you?",
                "Hello! I'm here to help. What do you need assistance with?"
            ]
            return responses.randomElement() ?? responses[0]
        }
        
        if lowercasedText.contains("thank") {
            let responses = [
                "You're welcome! Is there anything else I can help you with?",
                "Happy to help! Let me know if you need anything else.",
                "You're welcome! Feel free to ask if you have any other questions.",
                "Glad I could help! Is there anything else you need?"
            ]
            return responses.randomElement() ?? responses[0]
        }
        
        // Generic responses for other messages
        let genericResponses = [
            "I understand. How can I assist you with that?",
            "I see. What specific information or help do you need?",
            "Thanks for your message. Could you tell me more about what you're looking for?",
            "I'm here to help. What would you like to know?",
            "Got it. How can I help you with this?",
            "I understand your request. What would you like me to do?",
            "Thank you for reaching out. How can I assist you today?",
            "I'm ready to help. Could you provide more details about what you need?"
        ]
        
        return genericResponses.randomElement() ?? "How can I help you?"
    }
//    func sendMessageAsync(_ text: String, images: [UIImage]? = nil, files: [AttachedFile]? = nil) async {
//        // Create message immediately
//        let userMessage = ChatMessage(
//            content: text,
//            isUser: true,
//            type: determineMessageType(text: text, images: images, files: files),
//            images: images,
//            attachedFiles: files
//        )
//        
//        messages.append(userMessage)
//        
//        // Add typing indicator after small delay
//        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
//        
//        let typingMessage = ChatMessage(
//            content: "",
//            isUser: false,
//            type: .typing,
//            isTyping: true
//        )
//        messages.append(typingMessage)
//        
//        // Simulate AI response
//        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
//        
//        messages.removeAll { $0.isTyping }
//        
//        let responseText = images != nil || files != nil ?
//            "I received your message with \(images?.count ?? 0) images and \(files?.count ?? 0) files. How can I help you?" :
////            "I received your message: \"\(text)\". How can I help you further?"
//                    """
//                    💳 **Payment Information:**
//                    
//                    We accept the following payment methods:
//                    • Credit/Debit Cards (Visa, MasterCard, Amex, Discover)
//                    • Digital Wallets (PayPal, Apple Pay, Google Pay)
//                    • Bank Transfers (ACH, Wire)
//                    • Cryptocurrency (Bitcoin, Ethereum)
//                    
//                    All transactions are secured with 256-bit SSL encryption.
//                    
//                    Would you like to update your payment method or learn more about our payment security?
//                    """
//        let aiMessage = ChatMessage(
//            content: responseText,
//            isUser: false,
//            type: .text
//        )
//        messages.append(aiMessage)
//    }

    
//    func sendMessageAsync(_ text: String, images: [UIImage]? = nil, files: [AttachedFile]? = nil) async {
//         // Create message immediately
//         let userMessage = ChatMessage(
//             content: text,
//             isUser: true,
//             timestamp: Date(),
//             type: determineMessageType(text: text, images: images, files: files),
//             images: images,
//             attachedFiles: files
//         )
//         
//         // Add to messages
//         messages.append(userMessage)
//         
//         // Add typing indicator after small delay
//         Task {
//             try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
//             
//             let typingMessage = ChatMessage(
//                 content: "",
//                 isUser: false,
//                 timestamp: Date(),
//                 type: .typing,
//                 isTyping: true
//             )
//             messages.append(typingMessage)
//             
//             // Simulate AI response
//             try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
//             
//             // Remove typing and add response
//             messages.removeAll { $0.isTyping }
//             
//             let responseText = images != nil || files != nil ?
//                 "I received your message with \(images?.count ?? 0) images and \(files?.count ?? 0) files. How can I help you?" :
//                 "I received your message: \"\(text)\". How can I help you further?"
//             
//             let aiMessage = ChatMessage(
//                 content: responseText,
//                 isUser: false,
//                 timestamp: Date(),
//                 type: .text
//             )
//             messages.append(aiMessage)
//         }
//     }
     
     private func determineMessageType(text: String, images: [UIImage]?, files: [AttachedFile]?) -> MessageType {
         if images != nil && files != nil {
             return .mixed
         } else if images != nil {
             return .image
         } else if files != nil {
             return .file
         }
         return .text
     }
    // MARK: - Export Chat
    func exportChat() -> String {
        var exportText = "Chat Export - \(Date().formatted())\n"
        exportText += String(repeating: "=", count: 50) + "\n\n"
        
        for message in messages {
            let sender = message.isUser ? "You" : "Assistant"
            let time = message.timestamp.formatted(date: .abbreviated, time: .shortened)
            
            exportText += "[\(time)] \(sender):\n"
            exportText += message.content + "\n"
            
            if let files = message.attachedFiles {
                for file in files {
                    exportText += "📎 Attachment: \(file.name) (\(file.formattedSize))\n"
                }
            }
            
            if message.images != nil {
                exportText += "🖼️ [Image(s) attached]\n"
            }
            
            exportText += "\n"
        }
        
        return exportText
    }
}
//class ChatViewModel: ObservableObject {
//    @Published var messages: [ChatMessage] = []
//    @Published var messagesNew: [ChatMessageNew] = []
//    @Published var selectedCategory: String? = nil
//    @Published var showQuickActions = true
//    
//    @Published var quickActions = [
//        "View and download invoices",
//        "Update payment methods",
//        "Manage subscriptions and plans",
//        "Process refunds and credits"
//    ]
//    
//    init() {
////        loadInitialMessages()
//        loadSampleMessages()
//    }
//    
//      private func loadSampleMessages() {
//          messagesNew = [
//            ChatMessageNew(
//                  content: "What payment methods do you accept?",
//                  isUser: true,
//                  isRead: true
//              ),
//            ChatMessageNew(
//                  content: "We accept various payment methods including credit cards, debit cards, digital wallets, and bank transfers. Would you like specific details about any of these options?",
//                  isUser: false,
//                  isRead: true
//              ),
////            ChatMessageNew(
////                  content: "We accept various payment methods including credit cards, debit cards, digital wallets, and bank transfers. Would you like specific details about any of these options?",
////                  isUser: false,
////                  isRead: true
////              ),
//            
//            ChatMessageNew(
//                  content: "Could you help check on this?\nThe error occurred because Radix UI's SelectItem component cannot accept empty strings as values. This is a validation rule to prevent confusion between",
//                  isUser: true,
//                  isRead: true
//              )
//          ]
//      }
//    
////    private func loadInitialMessages() {
////        messages = [
////            ChatMessage(
////                content: "Hello! I'm your AI-powered assistant. Choose the options below or ask me anything.",
////                isUser: false,
////                type: .text
////            ),
////            ChatMessage(
////                content: "I need help with Billing & Payments",
////                isUser: true,
////                type: .text
////            ),
////            ChatMessage(
////                content: "I can assist with all billing matters! Here's what I can help you with:",
////                isUser: false,
////                type: .options,
////                options: [
////                    "View and download invoices",
////                    "Update payment methods",
////                    "Manage subscriptions and plans",
////                    "Process refunds and credits",
////                    "Resolve billing disputes",
////                    "Set up automatic payments",
////                    "Update billing addresses"
////                ]
////            ),
////            ChatMessage(
////                content: "What payment methods do you accept?",
////                isUser: true,
////                type: .text
////            ),
////            ChatMessage(
////                content: "We accept the following payment methods:\n\n• Credit/Debit Cards: Visa, MasterCard, American Express, and Discover\n• Digital Wallets: PayPal, Apple Pay, Google Pay\n• Bank Transfers: Available for selected banks\n• Cash on Delivery (COD): Available for certain locations\n\nWould you like to know more about any specific payment method?",
////                isUser: false,
////                type: .text
////            ),
////            ChatMessage(
////                content: "",
////                isUser: false,
////                type: .voice,
////                voiceDuration: "0:13"
////            ),
////            ChatMessage(
////                content: "incomplete_transaction_12082025.pdf",
////                isUser: true,
////                type: .file,
////                fileName: "incomplete_transaction_12082025.pdf",
////                fileSize: "200 KB"
////            ),
////            ChatMessage(
////                content: "",
////                isUser: false,
////                type: .card,
////                cardTitle: "Invoice #INV-2024-001",
////                cardSubtitle: "Due: Dec 31, 2024 • $250.00"
////            )
////        ]
////    }
////    func selectCategory(_ category: String) {
////          sendMessage("I need help with \(category)")
////      }
////    func sendMessage(_ text: String) {
////        guard !text.isEmpty else { return }
////        
////        let userMessage = ChatMessage(
////            content: text,
////            isUser: true,
////            type: .text
////        )
////        messages.append(userMessage)
////        
////        // Simulate bot response
////        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
////            let botMessage = ChatMessage(
////                content: "I understand your question about '\(text)'. Let me help you with that.",
////                isUser: false,
////                type: .text
////            )
////            self.messages.append(botMessage)
////        }
////    }
//    
////    func handleQuickAction(_ action: String) {
////        sendMessage(action)
////    }
//    
//    func toggleRecording() {
//        // Handle voice recording
//    }
//}
