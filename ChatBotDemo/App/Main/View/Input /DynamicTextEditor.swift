//
//  DynamicTextEditor.swift
//  ChatBotDemo
//
//  Created by Sombo Mobile R&D on 14/8/25.
//
import SwiftUI

struct DynamicTextEditor: View {
    
    @Binding var text   : String
    @Binding var height : CGFloat
    @FocusState var isFocused   : Bool
    
    let minHeight   : CGFloat
    let maxHeight   : CGFloat
    let placeholder : String
    var isDisabled  : Bool = false
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            if text.isEmpty && !isFocused {
                Text(placeholder)
                    .foregroundColor(isDisabled ? .gray.opacity(0.4) : .gray.opacity(0.6))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }
            
            TextEditor(text: $text)
                .focused($isFocused)
                .frame(minHeight: minHeight, maxHeight: maxHeight)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(isDisabled ? 0.6 : 1.0)
                .foregroundColor(isDisabled ? .gray : .primary)
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .disabled(isDisabled)  // Actually disable the editor
                .allowsHitTesting(!isDisabled)  // Prevent interaction when disabled
                .onChange(of: text) { newValue in
                    // Force UI update when text changes from voice input
                    if !newValue.isEmpty && !isDisabled {
                        updateHeight(calculateHeight(for: newValue))
                    }
                }
                .background(
                    // Hidden text view to measure height
                    Text(text.isEmpty ? " " : text)  // Use space instead of placeholder for consistent height
                        .font(.system(size: 16))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    updateHeight(geometry.size.height)
                                }
                                .onChange(of: geometry.size.height) { newHeight in
                                    updateHeight(newHeight)
                                }
                        })
                        .opacity(0)
                )
        }
    }
    
    private func calculateHeight(for text: String) -> CGFloat {
        // Estimate height based on text content
        let font = UIFont.systemFont(ofSize: 16)
        let textWidth = UIScreen.main.bounds.width - 100 // Approximate available width
        let boundingBox = text.boundingRect(
            with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return boundingBox.height + 16 // Add padding
    }
    
    private func updateHeight(_ newHeight: CGFloat) {
        let clampedHeight = min(max(newHeight, minHeight), maxHeight)
        if abs(clampedHeight - height) > 2 {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.15)) {
                    height = clampedHeight
                }
            }
        }
    }
}

// MARK: - Enhanced version with better voice input support
struct EnhancedDynamicTextEditor: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var height: CGFloat
    @FocusState var isFocused: Bool
    
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let placeholder: String
    var isDisabled: Bool = false  // Added with default value
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textColor = UIColor.label  // Always use label color for visibility
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.textContainer.lineFragmentPadding = 0
        textView.showsVerticalScrollIndicator = true
        textView.isEditable = !isDisabled
        textView.isUserInteractionEnabled = !isDisabled
        textView.contentInsetAdjustmentBehavior = .never
        
        // Accessibility for voice input
        textView.isAccessibilityElement = true
        textView.accessibilityTraits = .updatesFrequently
        
        // Set initial text and placeholder
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.placeholderText
        } else {
            textView.text = text
            textView.textColor = isDisabled ? UIColor.systemGray : UIColor.label
        }
        
        // Calculate initial height
        DispatchQueue.main.async {
            self.updateHeight(textView)
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update disabled state
        uiView.isEditable = !isDisabled
        uiView.isUserInteractionEnabled = !isDisabled
        uiView.alpha = isDisabled ? 0.6 : 1.0
        
        // Handle placeholder and text color
        if text.isEmpty && !uiView.isFirstResponder {
            uiView.text = placeholder
            uiView.textColor = UIColor.placeholderText
        } else if uiView.text == placeholder {
            uiView.text = text
            uiView.textColor = isDisabled ? UIColor.systemGray : UIColor.label
        } else if uiView.text != text {
            // Update text from voice input or other sources
            let wasFirstResponder = uiView.isFirstResponder
            let selectedRange = uiView.selectedRange
            
            uiView.text = text
            uiView.textColor = isDisabled ? UIColor.systemGray : UIColor.label
            
            // Maintain cursor position for better UX
            if !text.isEmpty && selectedRange.location != NSNotFound && !isDisabled {
                let newLocation = min(selectedRange.location, text.count)
                uiView.selectedRange = NSRange(location: newLocation, length: 0)
            }
            
            // Restore focus if needed and not disabled
            if wasFirstResponder && !isDisabled {
                uiView.becomeFirstResponder()
            }
            
            // Update height for new content
            updateHeight(uiView)
        }
        
        // Handle focus state (only if not disabled)
        if !isDisabled {
            DispatchQueue.main.async {
                if self.isFocused && !uiView.isFirstResponder {
                    uiView.becomeFirstResponder()
                } else if !self.isFocused && uiView.isFirstResponder {
                    uiView.resignFirstResponder()
                }
            }
        } else if uiView.isFirstResponder {
            // Force resign if disabled
            uiView.resignFirstResponder()
        }
    }
    
    private func updateHeight(_ textView: UITextView) {
        let fixedWidth = textView.frame.width > 0 ? textView.frame.width : UIScreen.main.bounds.width - 100
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: .infinity))
        let newHeight = min(max(newSize.height, minHeight), maxHeight)
        
        if abs(newHeight - height) > 2 {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.1)) {
                    self.height = newHeight
                    // Enable scrolling only when content exceeds max height
                    textView.isScrollEnabled = newHeight >= self.maxHeight
                    
                    // Scroll to bottom when text is added (useful for voice input)
                    if textView.isScrollEnabled && !self.isDisabled {
                        let bottom = NSMakeRange(textView.text.count - 1, 1)
                        textView.scrollRangeToVisible(bottom)
                    }
                }
            }
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: EnhancedDynamicTextEditor
        
        init(_ parent: EnhancedDynamicTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // Only update parent text if it's not the placeholder and not disabled
            if textView.textColor != UIColor.placeholderText && !parent.isDisabled {
                parent.text = textView.text
            }
            parent.updateHeight(textView)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            guard !parent.isDisabled else {
                textView.resignFirstResponder()
                return
            }
            
            parent.isFocused = true
            
            // Clear placeholder when editing starts
            if textView.textColor == UIColor.placeholderText {
                textView.text = ""
                textView.textColor = UIColor.label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
            
            // Show placeholder if text is empty
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.placeholderText
            }
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // Don't allow changes if disabled
            guard !parent.isDisabled else { return false }
            
            // Clear placeholder text when user starts typing
            if textView.textColor == UIColor.placeholderText && !text.isEmpty {
                textView.text = ""
                textView.textColor = UIColor.label
            }
            return true
        }
    }
}

