//
//  FilesList.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 22/8/25.
//
import SwiftUI

struct FilesList: View {
    let files: [AttachedFile]
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(files) { file in
                HStack {
                    Image(systemName: file.type.icon)
                        .foregroundColor(file.type.color)
                    Text(file.name)
                        .font(.caption)
                    Spacer()
                    Text(file.formattedSize)
                        .font(.caption2)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
    }
}
