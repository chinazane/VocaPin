//
//  TranscriptionError.swift
//  VocaPin
//
//  Created by Kiro on 8/26/25.
//

import Foundation

enum TranscriptionError: Error, LocalizedError {
    // File-related errors
    case fileNotFound
    case fileCorrupted
    case fileAccessDenied
    case unsupportedFileFormat
    case fileSizeExceeded
    
    // Audio-related errors
    case audioTooShort
    case audioTooLong
    case audioQualityTooLow
    case audioFormatUnsupported
    case audioChannelMismatch
    
    // System-related errors
    case networkUnavailable
    case speechRecognitionUnavailable
    case permissionDenied
    case insufficientMemory
    case deviceNotSupported
    
    // Transcription process errors
    case transcriptionFailed(String)
    case transcriptionTimeout
    case cancelled
    case serviceUnavailable
    case quotaExceeded
    
    var errorDescription: String? {
        switch self {
        // File-related errors
        case .fileNotFound:
            return "Audio file not found"
        case .fileCorrupted:
            return "Audio file is corrupted or unreadable"
        case .fileAccessDenied:
            return "Cannot access the audio file"
        case .unsupportedFileFormat:
            return "Audio file format is not supported"
        case .fileSizeExceeded:
            return "Audio file is too large to process"
            
        // Audio-related errors
        case .audioTooShort:
            return "Recording too short to transcribe"
        case .audioTooLong:
            return "Recording is too long for transcription"
        case .audioQualityTooLow:
            return "Audio quality is too low for accurate transcription"
        case .audioFormatUnsupported:
            return "Audio format is not supported for transcription"
        case .audioChannelMismatch:
            return "Audio channel configuration is not supported"
            
        // System-related errors
        case .networkUnavailable:
            return "Network connection required for transcription"
        case .speechRecognitionUnavailable:
            return "Speech recognition is not available on this device"
        case .permissionDenied:
            return "Speech recognition permission denied"
        case .insufficientMemory:
            return "Insufficient memory to process the audio file"
        case .deviceNotSupported:
            return "This device does not support speech recognition"
            
        // Transcription process errors
        case .transcriptionFailed(let message):
            return "Transcription failed: \(message)"
        case .transcriptionTimeout:
            return "Transcription timed out"
        case .cancelled:
            return "Transcription was cancelled"
        case .serviceUnavailable:
            return "Speech recognition service is temporarily unavailable"
        case .quotaExceeded:
            return "Speech recognition quota exceeded"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        // File-related errors
        case .fileNotFound:
            return "Please try recording again"
        case .fileCorrupted:
            return "Please record a new audio file"
        case .fileAccessDenied:
            return "Check file permissions and try again"
        case .unsupportedFileFormat:
            return "Please use a supported audio format (WAV, M4A, MP3)"
        case .fileSizeExceeded:
            return "Please record a shorter audio clip"
            
        // Audio-related errors
        case .audioTooShort:
            return "Please record for at least 1 second"
        case .audioTooLong:
            return "Please keep recordings under 60 seconds for optimal results"
        case .audioQualityTooLow:
            return "Try recording in a quieter environment with better audio quality"
        case .audioFormatUnsupported:
            return "Please record in a standard audio format"
        case .audioChannelMismatch:
            return "Please use mono or stereo audio recording"
            
        // System-related errors
        case .networkUnavailable:
            return "Check your internet connection and try again"
        case .speechRecognitionUnavailable:
            return "Speech recognition is not supported on this device"
        case .permissionDenied:
            return "Please enable speech recognition in Settings > Privacy & Security"
        case .insufficientMemory:
            return "Close other apps and try again"
        case .deviceNotSupported:
            return "Please use a device that supports speech recognition"
            
        // Transcription process errors
        case .transcriptionFailed:
            return "Please try again or check your audio quality"
        case .transcriptionTimeout:
            return "Try with a shorter audio file or check your connection"
        case .cancelled:
            return nil
        case .serviceUnavailable:
            return "Please try again later"
        case .quotaExceeded:
            return "Please try again later or contact support"
        }
    }
    
    var canRetry: Bool {
        switch self {
        // Retryable errors
        case .networkUnavailable, .transcriptionFailed, .transcriptionTimeout, 
             .serviceUnavailable, .insufficientMemory:
            return true
            
        // Non-retryable errors
        case .fileNotFound, .fileCorrupted, .fileAccessDenied, .unsupportedFileFormat, 
             .fileSizeExceeded, .audioTooShort, .audioTooLong, .audioQualityTooLow, 
             .audioFormatUnsupported, .audioChannelMismatch, .speechRecognitionUnavailable, 
             .permissionDenied, .deviceNotSupported, .cancelled, .quotaExceeded:
            return false
        }
    }
    
    /// Indicates the severity level of the error for logging and user feedback
    var severity: ErrorSeverity {
        switch self {
        case .cancelled:
            return .info
        case .audioTooShort, .audioTooLong, .audioQualityTooLow:
            return .warning
        case .networkUnavailable, .transcriptionTimeout, .serviceUnavailable:
            return .recoverable
        case .fileNotFound, .fileCorrupted, .transcriptionFailed, .insufficientMemory:
            return .error
        case .speechRecognitionUnavailable, .permissionDenied, .deviceNotSupported, 
             .quotaExceeded, .fileAccessDenied, .unsupportedFileFormat, .fileSizeExceeded,
             .audioFormatUnsupported, .audioChannelMismatch:
            return .critical
        }
    }
    
    /// Provides specific error recovery strategies
    var recoveryStrategy: ErrorRecoveryStrategy {
        switch self {
        case .networkUnavailable:
            return .retryWithDelay(seconds: 5)
        case .transcriptionTimeout, .serviceUnavailable:
            return .retryWithBackoff
        case .insufficientMemory:
            return .retryAfterCleanup
        case .audioQualityTooLow:
            return .suggestAlternative
        case .permissionDenied:
            return .requestPermission
        case .fileNotFound, .audioTooShort, .audioTooLong:
            return .requireUserAction
        default:
            return .none
        }
    }
}

// MARK: - Supporting Enums

enum ErrorSeverity {
    case info
    case warning
    case recoverable
    case error
    case critical
}

enum ErrorRecoveryStrategy {
    case none
    case retryWithDelay(seconds: Int)
    case retryWithBackoff
    case retryAfterCleanup
    case suggestAlternative
    case requestPermission
    case requireUserAction
}