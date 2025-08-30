//
//  FooterActionButtonsView.swift
//  VocaPin
//
//  Created by Kiro on 8/27/25.
//

import SwiftUI

struct FooterActionButtonsView: View {
    @Binding var showSpeechRecognition: Bool
    @Binding var showDeleteConfirmation: Bool
    let isTextEditorFocused: Bool
    let onEditTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 60) {
            // Delete button (left)
            Button(action: {
                showDeleteConfirmation = true
            }) {
                Circle()
                    .fill(Color.gray.opacity(0.7))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.1), value: showDeleteConfirmation)
            }
            .accessibilityLabel("Clear note content")
            .accessibilityHint("Clears all text from the current note")
            
            // Speaker button (center)
            Button(action: {
                showSpeechRecognition = true
            }) {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "mic.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.1), value: showSpeechRecognition)
            }
            .accessibilityLabel("Voice input")
            .accessibilityHint("Opens speech recognition to add voice input to note")
            
            // Edit button (right)
            Button(action: onEditTapped) {
                Circle()
                    .fill(isTextEditorFocused ? Color.blue.opacity(0.7) : Color.gray.opacity(0.7))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "pencil")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.2), value: isTextEditorFocused)
            }
            .accessibilityLabel("Edit note")
            .accessibilityHint("Activates text editing mode and shows keyboard")
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 30)
        .background(Color(red: 0.9, green: 0.85, blue: 0.8))
    }
}

// MARK: - Button Press Animation Extension
extension View {
    func buttonPressAnimation() -> some View {
        self.scaleEffect(1.0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    // Animation handled by individual button states
                }
            }
    }
}

#Preview {
    FooterActionButtonsView(
        showSpeechRecognition: .constant(false),
        showDeleteConfirmation: .constant(false),
        isTextEditorFocused: false,
        onEditTapped: { }
    )
    .previewLayout(.sizeThatFits)
}