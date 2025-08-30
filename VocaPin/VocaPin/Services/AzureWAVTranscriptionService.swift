import Foundation
import AVFoundation

@MainActor
class AzureWAVTranscriptionService: ObservableObject {
    @Published var isTranscribing: Bool = false
    @Published var transcriptionProgress: String = ""
    @Published var transcriptionError: TranscriptionError?
    
    private let azureSpeechService: AzureSpeechService
    

    
    init(azureSpeechService: AzureSpeechService = AzureSpeechService()) {
        self.azureSpeechService = azureSpeechService
    }
    
    // MARK: - Public Methods
    
    func transcribeWAVFile(at url: URL) async throws -> String {
        print("🎤 AzureWAVTranscriptionService: Starting Azure transcription for file: \(url.lastPathComponent)")
        
        // Reset state
        isTranscribing = true
        transcriptionProgress = "Preparing Azure transcription..."
        transcriptionError = nil
        
        do {
            // Validate file exists and is accessible
            try validateAudioFile(at: url)
            
            // Update progress
            transcriptionProgress = "Sending audio to Azure Speech Service..."
            
            // Perform transcription using Azure
            let transcribedText = try await performAzureTranscription(for: url)
            
            // Success
            transcriptionProgress = "Azure transcription completed"
            isTranscribing = false
            
            print("✅ AzureWAVTranscriptionService: Transcription successful: '\(transcribedText.prefix(50))...'")
            return transcribedText
            
        } catch {
            // Handle errors
            isTranscribing = false
            
            if let transcriptionError = error as? TranscriptionError {
                self.transcriptionError = transcriptionError
                print("❌ AzureWAVTranscriptionService: Transcription error: \(transcriptionError.localizedDescription)")
                throw transcriptionError
            } else if let azureError = error as? AzureSpeechError {
                let wrappedError = mapAzureErrorToTranscriptionError(azureError)
                self.transcriptionError = wrappedError
                print("❌ AzureWAVTranscriptionService: Azure error: \(azureError.localizedDescription)")
                throw wrappedError
            } else {
                let wrappedError = TranscriptionError.transcriptionFailed(error.localizedDescription)
                self.transcriptionError = wrappedError
                print("❌ AzureWAVTranscriptionService: Unexpected error: \(error.localizedDescription)")
                throw wrappedError
            }
        }
    }
    
    func cancelTranscription() {
        print("🛑 AzureWAVTranscriptionService: Cancelling Azure transcription")
        
        isTranscribing = false
        transcriptionProgress = "Azure transcription cancelled"
        transcriptionError = TranscriptionError.cancelled
    }
    
    func clearError() {
        transcriptionError = nil
    }
    
    // MARK: - Private Methods
    
    private func validateAudioFile(at url: URL) throws {
        print("🔍 AzureWAVTranscriptionService: Validating audio file at: \(url.path)")
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw TranscriptionError.fileNotFound
        }
        
        // Check file size and basic properties
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = fileAttributes[.size] as? Int64 ?? 0
            
            print("📊 AzureWAVTranscriptionService: File size: \(fileSize) bytes")
            
            // Basic file size validation (empty files are problematic)
            if fileSize < 1000 { // Less than 1KB is likely too short
                throw TranscriptionError.audioTooShort
            }
            
            // Check if file is too large (Azure has limits)
            if fileSize > 25 * 1024 * 1024 { // 25MB limit for Azure
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
            
            print("⏱️ AzureWAVTranscriptionService: Audio duration: \(duration) seconds")
            
            // Validate duration
            if duration < 0.5 {
                throw TranscriptionError.audioTooShort
            }
            
            if duration > 300 { // 5 minutes max for reasonable processing time
                throw TranscriptionError.audioTooLong
            }
            
        } catch {
            if error is TranscriptionError {
                throw error
            }
            print("⚠️ AzureWAVTranscriptionService: Could not read audio file properties: \(error)")
            throw TranscriptionError.fileCorrupted
        }
    }
    
    private func performAzureTranscription(for url: URL) async throws -> String {
        print("🎯 AzureWAVTranscriptionService: Starting Azure transcription process")
        
        // Update progress
        transcriptionProgress = "Processing with Azure Speech Service..."
        
        return try await withCheckedThrowingContinuation { continuation in
            // Use simple transcription without productivity prompt
            azureSpeechService.transcribeAudio(fileURL: url) { result in
                switch result {
                case .success(let transcribedText):
                    if transcribedText.isEmpty {
                        print("⚠️ AzureWAVTranscriptionService: Empty transcription result from Azure")
                        continuation.resume(throwing: TranscriptionError.transcriptionFailed("No speech detected in audio file"))
                    } else {
                        print("✅ AzureWAVTranscriptionService: Azure transcription received")
                        continuation.resume(returning: transcribedText)
                    }
                    
                case .failure(let azureError):
                    print("❌ AzureWAVTranscriptionService: Azure transcription error: \(azureError.localizedDescription)")
                    continuation.resume(throwing: azureError)
                }
            }
        }
    }
    
    private func mapAzureErrorToTranscriptionError(_ azureError: AzureSpeechError) -> TranscriptionError {
        switch azureError {
        case .invalidURL, .invalidAPIKey:
            return .serviceUnavailable
        case .noData, .invalidResponse:
            return .transcriptionFailed("Azure service returned invalid response")
        case .fileReadError:
            return .fileCorrupted
        case .unsupportedFileType(let type):
            return .unsupportedFileFormat
        case .transcriptionFailed(let message):
            return .transcriptionFailed("Azure: \(message)")
        case .networkError:
            return .networkUnavailable
        case .audioTooShort:
            return .audioTooShort
        case .audioTooLong:
            return .audioTooLong
        }
    }
}