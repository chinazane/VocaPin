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
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var timeRemaining: Int = 60
    @State private var totalTime: Int = 60
    @State private var timer: Timer?
    @State private var isRecording = false
    @State private var recognizedText = ""
    
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
            
            VStack(spacing: 40) {
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
                
                Spacer()
                
                // Title
                Text("Speaking View")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Enhanced circular timer with microphone
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                        .frame(width: 200, height: 200)
                    
                    // Progress indicator with dynamic color
                    Circle()
                        .trim(from: 0, to: CGFloat(progressPercentage))
                        .stroke(
                            progressColor,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                    
                    // Pulse effect when recording
                    if isRecording {
                        Circle()
                            .stroke(progressColor.opacity(0.3), lineWidth: 2)
                            .frame(width: 220, height: 220)
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
                                .font(.system(size: 40))
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
                .frame(height: 80)
                .padding(.horizontal, 40)
                
                // Recording status and recognized text
                VStack(spacing: 10) {
                    Text(isRecording ? "Recording..." : "Tap to start")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    if !recognizedText.isEmpty {
                        ScrollView {
                            Text(recognizedText)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxHeight: 100)
                    }
                }
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 60) {
                    // Redo button
                    Button(action: {
                        redoRecording()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    // Record/Stop button
                    Button(action: {
                        if isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(isRecording ? Color.red : Color.red)
                                .frame(width: 80, height: 80)
                            
                            if isRecording {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                            } else {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                    
                    // Done button
                    Button(action: {
                        stopRecording()
                        if !recognizedText.isEmpty {
                            onTextRecognized(recognizedText)
                        }
                        isPresented = false
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.green.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            requestSpeechPermission()
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
        // Request speech recognition permission
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                // Handle permission status if needed
            }
        }
        
        // Request microphone permission for audio recording
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    print("Microphone permission granted")
                } else {
                    print("Microphone permission denied")
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
}

#Preview {
    SpeechRecognitionView(isPresented: .constant(true)) { text in
        print("Recognized text: \(text)")
    }
}