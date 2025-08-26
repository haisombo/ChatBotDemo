//
//  FileMessageBubble.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//
import SwiftUI

struct FileMessageBubble: View {
    let message: ChatMessage
    var body: some View {
        if let files = message.attachedFiles {
            FilesList(files: files)
        }
    }
}
