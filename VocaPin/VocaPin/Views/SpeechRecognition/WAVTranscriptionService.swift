//
//  WAVTranscriptionService.swift
//  VocaPin
//
//  Created by Kiro on 8/26/25.
//

import Foundation
import Speech
import AVFoundation
import Network

@MainActor
class WAVTranscriptionService: ObservableObject {
    @Published var isTranscribing: Bool = false
    @Published var transcriptionProgress: String = ""
    @Published var transcriptionError: TranscriptionError?
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechURLRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "NetworkMonitor")
    private var isNetworkAvailable = false
    
    init() {
        setupNetworkMonitoring()
        setupSpeechRecognizer()
    }
    
    deinit {
        networkMonitor.cancel()
        // Cancel any ongoing transcription task
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
    
    // MARK: - Public Methods
    
    func transcribeWAVFile(at url: URL) async throws -> String {
        print("🎤 WAVTranscriptionService: Starting transcription for file: \(url.lastPathComponent)")
        
        // Reset state
        isTranscribing = true
        transcriptionProgress = "Preparing transcription..."
        transcriptionError = nil
        
        do {
            // Validate file exists and is accessible
            try validateAudioFile(at: url)
            
            // Check permissions
            try await checkSpeechRecognitionPermission()
            
            // Perform transcription
            let transcribedText = try await performTranscription(for: url)
            
            // Success
            transcriptionProgress = "Transcription completed"
            isTranscribing = false
            
            print("✅ WAVTranscriptionService: Transcription successful: '\(transcribedText.prefix(50))...'")
            return transcribedText
            
        } catch {
            // Handle errors
            isTranscribing = false
            
            if let transcriptionError = error as? TranscriptionError {
                self.transcriptionError = transcriptionError
                print("❌ WAVTranscriptionService: Transcription error: \(transcriptionError.localizedDescription)")
                throw transcriptionError
            } else {
                let wrappedError = TranscriptionError.transcriptionFailed(error.localizedDescription)
                self.transcriptionError = wrappedError
                print("❌ WAVTranscriptionService: Unexpected error: \(error.localizedDescription)")
                throw wrappedError
            }
        }
    }
    
    func cancelTranscription() {
        print("🛑 WAVTranscriptionService: Cancelling transcription")
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isTranscribing = false
        transcriptionProgress = "Transcription cancelled"
        transcriptionError = TranscriptionError.cancelled
    }
    
    func clearError() {
        transcriptionError = nil
    }
    
    // MARK: - Private Methods
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: networkQueue)
    }
    
    private func setupSpeechRecognizer() {
        // Try to create speech recognizer for current locale
        speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
        
        // Fallback to English if current locale is not supported
        if speechRecognizer == nil {
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        }
        
        print("🎤 WAVTranscriptionService: Speech recognizer setup - Available: \(speechRecognizer?.isAvailable ?? false)")
    }
    
    private func validateAudioFile(at url: URL) throws {
        print("🔍 WAVTranscriptionService: Validating audio file at: \(url.path)")
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw TranscriptionError.fileNotFound
        }
        
        // Check file size and basic properties
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = fileAttributes[.size] as? Int64 ?? 0
            
            print("📊 WAVTranscriptionService: File size: \(fileSize) bytes")
            
            // Basic file size validation (empty files are problematic)
            if fileSize < 1000 { // Less than 1KB is likely too short
                throw TranscriptionError.audioTooShort
            }
            
            // Check if file is too large (over 50MB might be problematic)
            if fileSize > 50 * 1024 * 1024 {
                throw TranscriptionError.audioTooLong
            }
            
        } catch {
            if error is TranscriptionError {
                throw error
            }
            throw TranscriptionError.fileCorrupted
        }
        
        // Try to get audio file duration
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
            
            print("⏱️ WAVTranscriptionService: Audio duration: \(duration) seconds")
            
            // Validate duration
            if duration < 0.5 {
                throw TranscriptionError.audioTooShort
            }
            
            if duration > 120 { // 2 minutes max for reasonable processing time
                throw TranscriptionError.audioTooLong
            }
            
        } catch {
            if error is TranscriptionError {
                throw error
            }
            print("⚠️ WAVTranscriptionService: Could not read audio file properties: \(error)")
            throw TranscriptionError.fileCorrupted
        }
    }
    
    private func checkSpeechRecognitionPermission() async throws {
        print("🔐 WAVTranscriptionService: Checking speech recognition permission")
        
        return try await withCheckedThrowingContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        print("✅ WAVTranscriptionService: Speech recognition authorized")
                        continuation.resume()
                    case .denied, .restricted:
                        print("❌ WAVTranscriptionService: Speech recognition denied/restricted")
                        continuation.resume(throwing: TranscriptionError.permissionDenied)
                    case .notDetermined:
                        print("❌ WAVTranscriptionService: Speech recognition not determined")
                        continuation.resume(throwing: TranscriptionError.permissionDenied)
                    @unknown default:
                        print("❌ WAVTranscriptionService: Speech recognition unknown status")
                        continuation.resume(throwing: TranscriptionError.speechRecognitionUnavailable)
                    }
                }
            }
        }
    }
    
    private func performTranscription(for url: URL) async throws -> String {
        print("🎯 WAVTranscriptionService: Starting transcription process")
        
        guard let speechRecognizer = speechRecognizer else {
            throw TranscriptionError.speechRecognitionUnavailable
        }
        
        guard speechRecognizer.isAvailable else {
            throw TranscriptionError.speechRecognitionUnavailable
        }
        
        // Update progress
        transcriptionProgress = isNetworkAvailable ? 
            "Transcribing audio file..." : 
            "Transcribing audio file (offline mode)..."
        
        return try await withCheckedThrowingContinuation { continuation in
            // Create recognition request for file
            let recognitionRequest = SFSpeechURLRecognitionRequest(url: url)
            recognitionRequest.shouldReportPartialResults = false
            recognitionRequest.requiresOnDeviceRecognition = !isNetworkAvailable
            
            print("🌐 WAVTranscriptionService: Using \(isNetworkAvailable ? "cloud" : "on-device") recognition")
            
            // Start recognition task
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("❌ WAVTranscriptionService: Recognition error: \(error.localizedDescription)")
                        
                        // Handle specific error types
                        if error.localizedDescription.contains("network") || error.localizedDescription.contains("internet") {
                            continuation.resume(throwing: TranscriptionError.networkUnavailable)
                        } else if error.localizedDescription.contains("cancelled") {
                            continuation.resume(throwing: TranscriptionError.cancelled)
                        } else {
                            continuation.resume(throwing: TranscriptionError.transcriptionFailed(error.localizedDescription))
                        }
                        return
                    }
                    
                    if let result = result {
                        if result.isFinal {
                            let transcribedText = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            if transcribedText.isEmpty {
                                print("⚠️ WAVTranscriptionService: Empty transcription result")
                                continuation.resume(throwing: TranscriptionError.transcriptionFailed("No speech detected in audio file"))
                            } else {
                                print("✅ WAVTranscriptionService: Final transcription received")
                                continuation.resume(returning: transcribedText)
                            }
                        } else {
                            // Update progress with partial results
                            let partialText = result.bestTranscription.formattedString
                            self.transcriptionProgress = "Transcribing: \(partialText.prefix(30))..."
                            print("📝 WAVTranscriptionService: Partial result: \(partialText.prefix(50))...")
                        }
                    }
                }
            }
            
            // Set up timeout for long transcriptions
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
                guard let self = self, self.isTranscribing else { return }
                
                print("⏰ WAVTranscriptionService: Transcription timeout")
                self.cancelTranscription()
                continuation.resume(throwing: TranscriptionError.transcriptionFailed("Transcription timed out"))
            }
        }
    }
}