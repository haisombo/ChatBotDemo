//
//  ChatMessage.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//
import Foundation
import UIKit
import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    
    let id = UUID()
    var content: String
    let isUser: Bool
    let timestamp: Date
    var type: MessageType
    
    // Media attachments
    var images: [UIImage]?
    var attachedFiles: [AttachedFile]?
    
    // Voice message properties
    var voiceDuration: String?
    var voiceWaveform: [Float]?
    
    // Card properties
    var cardTitle: String?
    var cardSubtitle: String?
    var cardActions: [CardAction]?
    
    // Options for quick replies
    var options: [String]?
    
    // Message status
    var isRead: Bool
    var isDelivered: Bool
    var isEdited: Bool
    var editedAt: Date?
    
    // Typing indicator
    var isTyping: Bool
    
    // Translation
    var translatedContent: String?
    var detectedLanguage: String?
    
    init(
        content: String = "",
        isUser: Bool,
        type: MessageType = .text,
        images: [UIImage]? = nil,
        attachedFiles: [AttachedFile]? = nil,
        voiceDuration: String? = nil,
        cardTitle: String? = nil,
        cardSubtitle: String? = nil,
        options: [String]? = nil,
        isTyping: Bool = false
    ) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.type = type
        self.images = images
        self.attachedFiles = attachedFiles
        self.voiceDuration = voiceDuration
        self.cardTitle = cardTitle
        self.cardSubtitle = cardSubtitle
        self.options = options
        self.isRead = false
        self.isDelivered = false
        self.isEdited = false
        self.isTyping = isTyping
        
        // Auto-detect mixed type
        if (images != nil || attachedFiles != nil) && !content.isEmpty {
            self.type = .mixed
        }
    }
    
    // MARK: - Equatable Conformance
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        // Compare all properties except closures and UIImages
        return lhs.id == rhs.id &&
               lhs.content == rhs.content &&
               lhs.isUser == rhs.isUser &&
               lhs.timestamp == rhs.timestamp &&
               lhs.type == rhs.type &&
               lhs.attachedFiles == rhs.attachedFiles &&
               lhs.voiceDuration == rhs.voiceDuration &&
               lhs.voiceWaveform == rhs.voiceWaveform &&
               lhs.cardTitle == rhs.cardTitle &&
               lhs.cardSubtitle == rhs.cardSubtitle &&
               lhs.options == rhs.options &&
               lhs.isRead == rhs.isRead &&
               lhs.isDelivered == rhs.isDelivered &&
               lhs.isEdited == rhs.isEdited &&
               lhs.editedAt == rhs.editedAt &&
               lhs.isTyping == rhs.isTyping &&
               lhs.translatedContent == rhs.translatedContent &&
               lhs.detectedLanguage == rhs.detectedLanguage &&
               compareImages(lhs.images, rhs.images) &&
               compareCardActions(lhs.cardActions, rhs.cardActions)
    }
    
    // Helper function to compare UIImage arrays
    private static func compareImages(_ lhs: [UIImage]?, _ rhs: [UIImage]?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            return true
        case (let left?, let right?):
            guard left.count == right.count else { return false }
            // Compare images by their data representation
            for (leftImage, rightImage) in zip(left, right) {
                let leftData = leftImage.pngData()
                let rightData = rightImage.pngData()
                if leftData != rightData {
                    return false
                }
            }
            return true
        default:
            return false
        }
    }
    
    // Helper function to compare CardAction arrays
    private static func compareCardActions(_ lhs: [CardAction]?, _ rhs: [CardAction]?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            return true
        case (let left?, let right?):
            guard left.count == right.count else { return false }
            // Compare CardActions by their properties (excluding closures)
            for (leftAction, rightAction) in zip(left, right) {
                if leftAction.id != rightAction.id ||
                   leftAction.title != rightAction.title ||
                   leftAction.icon != rightAction.icon {
                    return false
                }
            }
            return true
        default:
            return false
        }
    }
}


struct ChatMessageNew: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
    var isRead: Bool = false
    
    // Equatable conformance (automatic for simple types)
    static func == (lhs: ChatMessageNew, rhs: ChatMessageNew) -> Bool {
        return lhs.id == rhs.id &&
               lhs.content == rhs.content &&
               lhs.isUser == rhs.isUser &&
               lhs.timestamp == rhs.timestamp &&
               lhs.isRead == rhs.isRead
    }
}


// MARK: - CardAction
struct CardAction: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let icon: String?
    let action: () -> Void
    
    // Equatable conformance (excluding closure)
    static func == (lhs: CardAction, rhs: CardAction) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.icon == rhs.icon
        // Note: We cannot compare closures, so we exclude 'action'
    }
}
