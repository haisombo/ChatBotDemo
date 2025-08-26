//
//  AttachedFile.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//

import Foundation
import SwiftUI

enum MessageType {
    case text
    case image
    case file
    case voice
    case card
    case options
    case mixed
    case typing
}

struct AttachedFile: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let size: Int64
    let type: FileType
    let data: Data?
    let url: URL?
    let uploadProgress: Double?
    
    enum FileType: String {
        case pdf = "PDF"
        case doc = "DOC"
        case docx = "DOCX"
        case xlsx = "XLSX"
        case txt = "TXT"
        case zip = "ZIP"
        case image = "IMAGE"
        case other = "FILE"
        
        var icon: String {
            switch self {
            case .pdf: return "doc.fill"
            case .doc, .docx: return "doc.text.fill"
            case .xlsx: return "tablecells.fill"
            case .txt: return "doc.plaintext.fill"
            case .zip: return "doc.zipper"
            case .image: return "photo.fill"
            case .other: return "doc.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .pdf: return .red
            case .doc, .docx: return .blue
            case .xlsx: return .green
            case .txt: return .gray
            case .zip: return .orange
            case .image: return .purple
            case .other: return .indigo
            }
        }
    }
    
    static func getFileType(from extension: String) -> FileType {
        switch `extension`.lowercased() {
        case "pdf": return .pdf
        case "doc": return .doc
        case "docx": return .docx
        case "xlsx", "xls": return .xlsx
        case "txt": return .txt
        case "zip", "rar", "7z": return .zip
        case "jpg", "jpeg", "png", "gif", "heic": return .image
        default: return .other
        }
    }
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

