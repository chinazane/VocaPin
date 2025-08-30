//
//  SpeechRecognitionView.swift
//  VocaPin
//
//  Created by Kiro on 8/26/25.
//

import SwiftUI
import Speech
import AVFoundation

struct SpeechRecognitionView: View {
    @Binding var isPresented: Bool
    let onTextRecognized: (String) -> Void
    @StateObject private var speechRecognizer = AzureSpeechRecognizer()
    @StateObject private var transcriptionService = AzureWAVTranscriptionService()
    @State private var timeRemaining: Int = 60
    @State private var totalTime: Int = 60
    @State private var timer: Timer?
    @State private var isRecording = false
    @State private var recognizedText = ""
    @State private var isTranscribing = false
    @State private var showTranscriptionProgress = false
    
    // Automatic AI processing states
    @State private var isAutoProcessingAI = false
    @State private var autoAIError: String?
    @State private var showingAutoAIError = false
    @State private var pendingTranscript: String?
    
    // AI Service
    private let aiService = AzureChatGPT4OService()
    
    // Enhanced progress calculation
    private var progressPercentage: Double {
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }
    
    private var progressColor: Color {
        let progress = progressPercentage
        if progress < 0.5 {
            return .green
        } else if progress < 0.8 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        stopRecording()
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Title
                VStack(spacing: 4) {
                    Text("AI Speaking View")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Recording started automatically")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .opacity(0.8)
                }
                .padding(.bottom, 20)
                
                // Main content area with flexible spacing
                VStack(spacing: 20) {
                    // Enhanced circular timer with microphone
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                            .frame(width: 180, height: 180)
                        
                        // Progress indicator with dynamic color
                        Circle()
                            .trim(from: 0, to: CGFloat(progressPercentage))
                            .stroke(
                                progressColor,
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 180, height: 180)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                        
                        // Pulse effect when recording
                        if isRecording {
                            Circle()
                                .stroke(progressColor.opacity(0.3), lineWidth: 2)
                                .frame(width: 200, height: 200)
                                .scaleEffect(isRecording ? 1.1 : 1.0)
                                .opacity(isRecording ? 0.6 : 0.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isRecording)
                        }
                        
                        VStack(spacing: 8) {
                            // Enhanced microphone icon with recording indicator
                            ZStack {
                                if isRecording {
                                    Circle()
                                        .fill(progressColor.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                        .scaleEffect(isRecording ? 1.2 : 1.0)
                                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isRecording)
                                }
                                
                                Image(systemName: isRecording ? "mic.fill" : "mic")
                                    .font(.system(size: 35))
                                    .foregroundColor(isRecording ? progressColor : .white)
                                    .animation(.easeInOut(duration: 0.3), value: isRecording)
                            }
                            
                            // Enhanced timer display
                            VStack(spacing: 2) {
                                Text(String(format: "%d:%02d", timeRemaining / 60, timeRemaining % 60))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .monospacedDigit()
                                
                                // Progress percentage
                                if isRecording {
                                    Text("\(Int(progressPercentage * 100))%")
                                        .font(.caption)
                                        .foregroundColor(progressColor)
                                        .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                                }
                            }
                        }
                    }
                    
                    // Audio wave visualization
                    AudioWaveView(
                        isRecording: isRecording, 
                        audioLevel: speechRecognizer.audioLevel,
                        smoothedAudioLevel: speechRecognizer.smoothedAudioLevel,
                        peakAudioLevel: speechRecognizer.peakAudioLevel,
                        waveformData: speechRecognizer.waveformData
                    )
                    .frame(height: 60)
                    .padding(.horizontal, 40)
                }
                
                // Flexible spacer to push content up and buttons down
                Spacer(minLength: 20)
                
                // Status and transcription area with fixed height
                VStack(spacing: 12) {
                    // Processing progress UI (Azure transcription or AI summarization)
                    if showTranscriptionProgress || isAutoProcessingAI {
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .progressViewStyle(CircularProgressViewStyle(tint: isAutoProcessingAI ? .orange : .blue))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(isAutoProcessingAI ? "Auto-summarizing with AI..." : transcriptionService.transcriptionProgress)
                                        .font(.caption)
                                        .foregroundColor(isAutoProcessingAI ? .orange : .blue)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text(isAutoProcessingAI ? "AI Summary Service" : "Azure Speech Service")
                                        .font(.caption2)
                                        .foregroundColor(isAutoProcessingAI ? Color.orange.opacity(0.7) : Color.blue.opacity(0.7))
                                }
                                
                                Spacer()
                            }
                            
                            // Cancel processing button
                            if transcriptionService.isTranscribing {
                                Button("Cancel Azure Transcription") {
                                    transcriptionService.cancelTranscription()
                                    showTranscriptionProgress = false
                                    isTranscribing = false
                                }
                                .font(.caption2)
                                .foregroundColor(.red)
                            } else if isAutoProcessingAI {
                                Button("Cancel AI Processing") {
                                    cancelAutoAIProcessing()
                                }
                                .font(.caption2)
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                    } else {
                        // Recording status and recognized text (compact version)
                        VStack(spacing: 8) {
                            Text(getStatusText())
                                .font(.subheadline)
                                .foregroundColor(getStatusColor())
                            
                            if !recognizedText.isEmpty {
                                ScrollView {
                                    Text(recognizedText)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxHeight: 60)
                            }
                        }
                    }
                }
                .frame(minHeight: 80, maxHeight: 120)
                
                // Control buttons - always visible at bottom
                VStack(spacing: 0) {
                    HStack(spacing: 50) {
                        // Redo button
                        Button(action: {
                            redoRecording()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 55, height: 55)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .disabled(isTranscribing || isAutoProcessingAI)
                        
                        // Stop button (recording starts automatically)
                        Button(action: {
                            stopRecording()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 70, height: 70)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .disabled(isTranscribing || isAutoProcessingAI)
                        
                        // Done button
                        Button(action: {
                            handleDoneAction()
                        }) {
                            Image(systemName: "checkmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 55, height: 55)
                                .background(Color.green.opacity((isTranscribing || isAutoProcessingAI) ? 0.4 : 0.7))
                                .clipShape(Circle())
                        }
                        .disabled(isTranscribing || isAutoProcessingAI)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            requestSpeechPermission()
            // Auto-start recording when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !isRecording && !isTranscribing && !isAutoProcessingAI {
                    startRecording()
                }
            }
        }
        .onDisappear {
            stopRecording()
        }
        .alert("Recording Error", isPresented: $speechRecognizer.showError) {
            if let error = speechRecognizer.currentError, let recoveryAction = error.recoveryAction {
                Button(recoveryAction) {
                    handleRecoveryAction(for: error)
                }
                Button("Cancel", role: .cancel) {
                    speechRecognizer.dismissError()
                }
            } else {
                Button("OK") {
                    speechRecognizer.dismissError()
                }
            }
        } message: {
            Text(speechRecognizer.errorMessage)
        }
        .alert("Transcription Error", isPresented: Binding<Bool>(
            get: { transcriptionService.transcriptionError != nil },
            set: { _ in transcriptionService.transcriptionError = nil }
        )) {
            if let error = transcriptionService.transcriptionError {
                if error.canRetry {
                    Button("Retry") {
                        retryTranscription()
                    }
                    Button("Use Real-time Text") {
                        useRealtimeText()
                    }
                    Button("Cancel", role: .cancel) {
                        transcriptionService.transcriptionError = nil
                        showTranscriptionProgress = false
                        isTranscribing = false
                    }
                } else {
                    Button("Use Real-time Text") {
                        useRealtimeText()
                    }
                    Button("Cancel", role: .cancel) {
                        transcriptionService.transcriptionError = nil
                        showTranscriptionProgress = false
                        isTranscribing = false
                    }
                }
            }
        } message: {
            if let error = transcriptionService.transcriptionError {
                VStack(alignment: .leading, spacing: 4) {
                    Text(error.errorDescription ?? "Unknown error")
                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.caption)
                    }
                }
            }
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
    }
    
    private func startRecording() {
        guard !isRecording else { return }
        
        isRecording = true
        timeRemaining = totalTime
        recognizedText = ""
        
        // Start speech recognition
        speechRecognizer.startRecording { text in
            recognizedText = text
        }
        
        // Start countdown timer with enhanced feedback
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                
                // Provide haptic feedback at certain intervals
                if timeRemaining == 10 || timeRemaining == 5 {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            } else {
                // Time's up - provide strong haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
        speechRecognizer.stopRecording()
    }
    
    private func redoRecording() {
        stopRecording()
        recognizedText = ""
        timeRemaining = totalTime
    }
    
    private func requestSpeechPermission() {
        // Request microphone permission for audio recording (Azure doesn't need Speech Recognition permission)
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Microphone permission granted for Speech Service")
                } else {
                    print("❌ Microphone permission denied")
                }
            }
        }
    }
    
    private func handleRecoveryAction(for error: AudioRecordingError) {
        switch error {
        case .permissionDenied:
            openAppSettings()
        case .fileCreationFailed, .insufficientStorage:
            openStorageSettings()
        case .networkError:
            // Could open network settings or just dismiss
            speechRecognizer.dismissError()
        case .recordingInterrupted, .audioSessionFailed, .unknownError:
            // Try to restart recording
            speechRecognizer.dismissError()
            if !isRecording {
                startRecording()
            }
        case .speechRecognitionUnavailable:
            speechRecognizer.dismissError()
        }
    }
    
    private func openAppSettings() {
        speechRecognizer.dismissError()
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func openStorageSettings() {
        speechRecognizer.dismissError()
        if let settingsUrl = URL(string: "App-prefs:General&path=STORAGE_MGMT") {
            UIApplication.shared.open(settingsUrl)
        } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    // MARK: - Transcription Methods
    
    private func getStatusText() -> String {
        if isAutoProcessingAI {
            return "Auto-summarizing with AI..."
        } else if isTranscribing {
            return "Processing with Azure..."
        } else if isRecording {
            return "Recording for note..."
        } else {
            return "Starting recording..."
        }
    }
    
    private func getStatusColor() -> Color {
        if isAutoProcessingAI || isTranscribing {
            return .orange
        } else if isRecording {
            return .blue
        } else {
            return .blue
        }
    }
    
    private func handleDoneAction() {
        stopRecording()
        
        // Check if we have a recorded WAV file to transcribe
        if let recordingURL = speechRecognizer.getLastRecordingURL(),
           speechRecognizer.isLastRecordingValidForTranscription() {
            
            // Start WAV file transcription
            startWAVTranscription(url: recordingURL)
        } else {
            // Fall back to real-time transcription text
            useRealtimeText()
        }
    }
    
    private func startWAVTranscription(url: URL) {
        isTranscribing = true
        showTranscriptionProgress = true
        
        Task {
            do {
                let transcribedText = try await transcriptionService.transcribeWAVFile(at: url)
                
                await MainActor.run {
                    recognizedText = transcribedText
                    isTranscribing = false
                    showTranscriptionProgress = false
                    
                    // Check if we should trigger automatic AI processing
                    if aiService.shouldAutoSummarize(transcribedText) {
                        processWithAutoAI(transcribedText)
                    } else {
                        // Complete without AI processing
                        onTextRecognized(transcribedText)
                        isPresented = false
                    }
                }
            } catch {
                await MainActor.run {
                    isTranscribing = false
                    // Error handling is done through the transcriptionService.transcriptionError binding
                }
            }
        }
    }
    
    private func retryTranscription() {
        transcriptionService.transcriptionError = nil
        
        if let recordingURL = speechRecognizer.getLastRecordingURL() {
            startWAVTranscription(url: recordingURL)
        } else {
            useRealtimeText()
        }
    }
    
    private func useRealtimeText() {
        transcriptionService.transcriptionError = nil
        showTranscriptionProgress = false
        isTranscribing = false
        
        if !recognizedText.isEmpty {
            // Check if we should trigger automatic AI processing
            if aiService.shouldAutoSummarize(recognizedText) {
                processWithAutoAI(recognizedText)
            } else {
                // Complete without AI processing
                onTextRecognized(recognizedText)
                isPresented = false
            }
        } else {
            isPresented = false
        }
    }
    
    // MARK: - Automatic AI Processing Functions
    
    /// Process text with automatic AI summarization
    private func processWithAutoAI(_ text: String) {
        guard aiService.shouldAutoSummarize(text) else {
            print("📝 Auto AI: Text too short for automatic summarization")
            onTextRecognized(text)
            isPresented = false
            return
        }
        
        pendingTranscript = text
        isAutoProcessingAI = true
        
        Task {
            do {
                print("🤖 Auto AI Summary: Starting processing for text: '\(text.prefix(50))...'")
                
                let aiResponse = try await aiService.generateSummary(for: text)
                
                await MainActor.run {
                    self.isAutoProcessingAI = false
                    self.pendingTranscript = nil
                    
                    print("✨ Auto AI Summary Response:")
                    print("=" * 50)
                    print(aiResponse)
                    print("=" * 50)
                    print("🎉 Auto AI Summary completed successfully!")
                    
                    // Complete with AI-summarized text
                    self.onTextRecognized(aiResponse)
                    self.isPresented = false
                }
                
            } catch {
                await MainActor.run {
                    self.autoAIError = "Failed to generate automatic AI summary: \(error.localizedDescription)"
                    self.showingAutoAIError = true
                    
                    print("❌ Auto AI Summary Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Cancel automatic AI processing
    private func cancelAutoAIProcessing() {
        isAutoProcessingAI = false
        autoAIError = nil
        
        // Use original transcript instead
        if let transcript = pendingTranscript {
            onTextRecognized(transcript)
        }
        pendingTranscript = nil
        isPresented = false
    }
    
    /// Retry automatic AI processing after an error
    private func retryAutoAIProcessing() {
        guard let transcript = pendingTranscript else {
            autoAIError = "No transcript available for retry"
            showingAutoAIError = true
            return
        }
        
        autoAIError = nil
        showingAutoAIError = false
        processWithAutoAI(transcript)
    }
    
    /// Keep the original transcribed text without AI processing
    private func keepOriginalText() {
        isAutoProcessingAI = false
        
        if let transcript = pendingTranscript {
            onTextRecognized(transcript)
        }
        
        autoAIError = nil
        pendingTranscript = nil
        isPresented = false
    }
}

// MARK: - Helper Extension
private extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

#Preview {
    SpeechRecognitionView(isPresented: .constant(true)) { text in
        print("Recognized text: \(text)")
    }
}
