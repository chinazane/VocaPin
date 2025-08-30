//
//  NotebookEditingView.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/22/25.
//

import SwiftUI
import WidgetKit

struct NotebookEditingView: View {
    @Binding var isPresented: Bool
    @Binding var note: Note
    @State private var editingText: String = ""
    @FocusState private var isTextEditorFocused: Bool
    
    // AI Summary states
    @State private var isProcessingAI = false
    @State private var aiSummaryError: String?
    @State private var showingAIError = false
    
    // Footer action states
    @State private var showSpeechRecognition = false
    @State private var showDeleteConfirmation = false
    
    // Automatic AI processing states
    @State private var isAutoProcessingAI = false
    @State private var autoAIError: String?
    @State private var showingAutoAIError = false
    @State private var pendingTranscript: String?
    
    // AI Service
    private let aiService = AzureChatGPT4OService()
    
    // MARK: - Computed Properties for Enhanced UI State
    
    /// Enhanced status text that handles both manual and automatic AI processing
    private var aiStatusText: String {
        if isAutoProcessingAI {
            return "Auto-summarizing with AI..."
        } else if isProcessingAI {
            return "Processing with AI..."
        } else if !editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Ready for AI processing"
        } else {
            return "Enter text to summarize"
        }
    }
    
    /// Enhanced status color that reflects current processing state
    private var aiStatusColor: Color {
        if isAutoProcessingAI || isProcessingAI {
            return .orange
        } else if !editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .green
        } else {
            return .secondary
        }
    }
    
    /// Determines if AI processing can be initiated (conflict prevention)
    private var canProcessAI: Bool {
        return !isProcessingAI && !isAutoProcessingAI
    }
    
    /// Enhanced button text that reflects current processing state
    private var aiButtonText: String {
        if isAutoProcessingAI {
            return "Auto-processing..."
        } else if isProcessingAI {
            return "Processing..."
        } else {
            return "AI Summary"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Cork board background
                Color(red: 0.9, green: 0.85, blue: 0.8)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Navigation bar
                    HStack {
                        Button("Cancel") {
                            isPresented = false
                        }
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("Edit Note")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button("Done") {
                            note.text = editingText
                            // Force immediate widget sync when note is edited
                            WidgetCenter.shared.reloadAllTimelines()
                            isPresented = false
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    // AI Summary toolbar
                    HStack {
                        Button(action: generateAISummary) {
                            HStack(spacing: 8) {
                                if isProcessingAI || isAutoProcessingAI {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                Text(aiButtonText)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                        }
                        .disabled(!canProcessAI || editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        Spacer()
                        
                        // Enhanced status indicator with automatic processing support
                        Text(aiStatusText)
                            .font(.caption)
                            .foregroundColor(aiStatusColor)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                    
                    // Large sticky note for editing
                    ZStack {
                        // Note shadow
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.15))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .offset(x: 6, y: 6)
                        
                        // Main note
                        RoundedRectangle(cornerRadius: 16)
                            .fill(note.color)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(
                                VStack {
                                    Spacer()
                                    
                                    // Text editor
                                    TextEditor(text: $editingText)
                                        .font(.custom("Marker Felt", size: 28))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 20)
                                        .background(Color.clear)
                                        .scrollContentBackground(.hidden)
                                        .focused($isTextEditorFocused)
                                    
                                    Spacer()
                                }
                            )
                    }
                    .overlay(
                        // Red pin (head only, no needle)
                        VStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .fill(Color.white.opacity(0.4))
                                        .frame(width: 22, height: 22)
                                        .offset(x: -4, y: -4)
                                )
                                .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 2)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .offset(y: -16)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Footer action buttons
                    FooterActionButtonsView(
                        showSpeechRecognition: $showSpeechRecognition,
                        showDeleteConfirmation: $showDeleteConfirmation,
                        isTextEditorFocused: isTextEditorFocused,
                        onEditTapped: {
                            isTextEditorFocused = true
                        }
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            editingText = note.text
            // Do not auto-focus - let user tap Edit button to activate keyboard
        }
        .alert("AI Summary Error", isPresented: $showingAIError) {
            Button("OK") { }
        } message: {
            Text(aiSummaryError ?? "An unknown error occurred")
        }
        .alert("Automatic AI Processing Error", isPresented: $showingAutoAIError) {
            Button("Retry") {
                retryAutoAIProcessing()
            }
            Button("Keep Original Text") {
                keepOriginalText()
            }
            Button("Cancel", role: .cancel) {
                cancelAutoAIProcessing()
            }
        } message: {
            Text(autoAIError ?? "An error occurred during automatic AI processing")
        }
        .sheet(isPresented: $showSpeechRecognition) {
            SpeechRecognitionView(isPresented: $showSpeechRecognition) { recognizedText in
                handleSpeechRecognitionCompletion(recognizedText)
            }
        }
        .alert("Clear Note Content", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearNoteContent()
            }
        } message: {
            Text("Are you sure you want to clear this note? This action cannot be undone.")
        }
    }
    
    // MARK: - AI Summary Functions
    
    private func generateAISummary() {
        guard !editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            aiSummaryError = "Please enter some text to summarize"
            showingAIError = true
            return
        }
        
        guard canProcessAI else {
            aiSummaryError = "AI processing is already in progress"
            showingAIError = true
            return
        }
        
        isProcessingAI = true
        
        Task {
            do {
                print("🤖 AI Summary: Starting processing for text: '\(editingText.prefix(50))...'")
                
                let aiResponse = try await aiService.generateSummary(for: editingText)
                
                await MainActor.run {
                    self.isProcessingAI = false
                    
                    // Replace the original text with AI summary
                    self.editingText = aiResponse
                    
                    // Log the AI response to console as requested
                    /*print("✨ AI Summary Response:")
                    print("=" * 50)
                    print(aiResponse)
                    print("=" * 50)*/
                    print("🎉 AI Summary completed successfully!")
                }
                
            } catch {
                await MainActor.run {
                    self.isProcessingAI = false
                    self.aiSummaryError = "Failed to generate AI summary: \(error.localizedDescription)"
                    self.showingAIError = true
                    
                    print("❌ AI Summary Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Speech Recognition Functions
    
    /// Handles speech recognition completion and triggers automatic AI processing if applicable
    private func handleSpeechRecognitionCompletion(_ recognizedText: String) {
        guard !recognizedText.isEmpty else { return }
        
        DispatchQueue.main.async {
            // First, add the recognized text to the editor
            if self.editingText.isEmpty {
                self.editingText = recognizedText
            } else {
                self.editingText += " " + recognizedText
            }
            
            // Ensure the text editor is focused after adding text
            self.isTextEditorFocused = true
            
            // Check if we should trigger automatic AI processing
            if self.aiService.shouldAutoSummarize(recognizedText) && self.canProcessAI {
                // Trigger automatic AI processing with the recognized text
                self.processWithAutoAI(recognizedText)
            }
        }
    }
    
    // MARK: - Automatic AI Processing Functions
    
    /// Retry automatic AI processing after an error
    private func retryAutoAIProcessing() {
        guard let transcript = pendingTranscript else {
            autoAIError = "No transcript available for retry"
            showingAutoAIError = true
            return
        }
        
        processWithAutoAI(transcript)
    }
    
    /// Keep the original transcribed text without AI processing
    private func keepOriginalText() {
        isAutoProcessingAI = false
        autoAIError = nil
        pendingTranscript = nil
        // Text is already in editingText, so no action needed
    }
    
    /// Cancel automatic AI processing
    private func cancelAutoAIProcessing() {
        isAutoProcessingAI = false
        autoAIError = nil
        pendingTranscript = nil
    }
    
    /// Process text with automatic AI summarization
    /// Note: The original transcript should already be added to editingText before calling this method
    private func processWithAutoAI(_ text: String) {
        // Validate text length before processing
        guard aiService.shouldAutoSummarize(text) else {
            print("📝 Auto AI: Text too short for automatic summarization (word count < 10)")
            return
        }
        
        guard canProcessAI else {
            print("⚠️ Auto AI: Cannot process - AI processing already in progress")
            return
        }
        
        pendingTranscript = text
        isAutoProcessingAI = true
        
        Task {
            do {
                print("🤖 Auto AI Summary: Starting processing for text: '\(text.prefix(50))...'")
                print("📊 Auto AI: Text validation - word count: \(text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count)")
                
                let aiResponse = try await aiService.generateSummary(for: text)
                
                await MainActor.run {
                    self.isAutoProcessingAI = false
                    self.pendingTranscript = nil
                    
                    // Replace the original transcript with AI summary
                    // The original transcript was already added to editingText in handleSpeechRecognitionCompletion
                    self.editingText = aiResponse
                    
                    print("✨ Auto AI Summary Response:")
                    print("=" * 50)
                    print(aiResponse)
                    print("=" * 50)
                    print("🎉 Auto AI Summary completed successfully!")
                }
                
            } catch {
                await MainActor.run {
                    self.autoAIError = "Failed to generate automatic AI summary: \(error.localizedDescription)"
                    self.showingAutoAIError = true
                    
                    print("❌ Auto AI Summary Error: \(error.localizedDescription)")
                    print("🔄 Auto AI: Original transcript preserved in editor")
                }
            }
        }
    }
    
    // MARK: - Delete Functions
    
    private func clearNoteContent() {
        editingText = ""
        note.text = ""
        // Force immediate widget sync when note is cleared
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Helper Extension
private extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

#Preview {
    NotebookEditingView(
        isPresented: .constant(true),
        note: .constant(Note(text: "Sample note text\nfor editing", position: CGPoint(x: 0, y: 0), rotation: 0))
    )
}
