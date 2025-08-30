# Design Document

## Overview

This document outlines the design for implementing WAV file transcription functionality in the VocaPin app. The feature will allow users to transcribe recorded audio files after completing a voice recording session, providing an alternative to real-time transcription with potentially higher accuracy.

## Architecture

### High-Level Flow

1. **Recording Phase**: User records audio using existing SpeechRecognitionView
2. **Completion Phase**: User taps green Complete button to finish recording
3. **Transcription Phase**: System transcribes the saved WAV file
4. **Integration Phase**: Transcribed text replaces current sticky note content
5. **Sync Phase**: Updated note is saved and synced to widget

### Component Interaction

```
SpeechRecognitionView
    ↓ (Complete button tapped)
WAVTranscriptionService
    ↓ (Transcription request)
SFSpeechRecognizer (File-based)
    ↓ (Transcription result)
ContentView (Note update)
    ↓ (Data persistence)
DataManager & WidgetSync
```

## Components and Interfaces

### 1. WAVTranscriptionService

**Purpose**: Handles transcription of saved WAV audio files

**Key Methods**:
```swift
class WAVTranscriptionService: ObservableObject {
    @Published var isTranscribing: Bool = false
    @Published var transcriptionProgress: String = ""
    @Published var transcriptionError: TranscriptionError?
    
    func transcribeWAVFile(at url: URL) async throws -> String
    func cancelTranscription()
    private func setupSpeechRecognizer() -> SFSpeechRecognizer?
    private func createRecognitionRequest(for audioFile: URL) -> SFSpeechURLRecognitionRequest
}
```

**Properties**:
- `isTranscribing`: Boolean indicating transcription status
- `transcriptionProgress`: Status message for UI display
- `transcriptionError`: Error information for user feedback

### 2. Enhanced SpeechRecognitionView

**Modifications Required**:
- Add transcription state management
- Modify Complete button behavior
- Add loading UI for transcription process
- Integrate with WAVTranscriptionService

**New State Variables**:
```swift
@StateObject private var transcriptionService = WAVTranscriptionService()
@State private var isTranscribingFile = false
@State private var transcriptionStatus = ""
```

**Updated Complete Button Logic**:
```swift
private func handleCompleteAction() async {
    stopRecording() // Stop current recording
    
    guard let recordedFileURL = speechRecognizer.lastRecordingURL else {
        // No file to transcribe, use real-time text
        completeWithCurrentText()
        return
    }
    
    // Start file transcription
    await transcribeRecordedFile(url: recordedFileURL)
}
```

### 3. TranscriptionError Enum

**Purpose**: Define specific error types for transcription failures

```swift
enum TranscriptionError: Error, LocalizedError {
    case fileNotFound
    case fileCorrupted
    case audioTooShort
    case audioTooLong
    case networkUnavailable
    case speechRecognitionUnavailable
    case permissionDenied
    case transcriptionFailed(String)
    
    var errorDescription: String? { ... }
    var recoverySuggestion: String? { ... }
}
```

### 4. Enhanced SpeechRecognizer

**Additional Properties**:
```swift
@Published var lastRecordingURL: URL?
private var currentRecordingURL: URL?
```

**Modified Methods**:
- Update `setupAudioRecording()` to store file URL
- Ensure WAV file is properly finalized after recording

## Data Models

### AudioFileMetadata

**Purpose**: Store metadata about recorded audio files

```swift
struct AudioFileMetadata {
    let url: URL
    let duration: TimeInterval
    let fileSize: Int64
    let recordingDate: Date
    let sampleRate: Double
    let channels: Int
}
```

## Error Handling

### Error Categories

1. **File System Errors**
   - File not found
   - File corrupted
   - Insufficient storage

2. **Audio Processing Errors**
   - Invalid audio format
   - Audio too short/long
   - Audio quality issues

3. **Speech Recognition Errors**
   - Service unavailable
   - Network connectivity
   - Permission denied

4. **System Errors**
   - Memory limitations
   - Processing timeout
   - Unexpected failures

### Error Recovery Strategies

1. **Automatic Retry**: For network-related failures
2. **Fallback Options**: Use real-time transcription if file transcription fails
3. **User Guidance**: Clear error messages with actionable steps
4. **Graceful Degradation**: Maintain app functionality even if transcription fails

## Testing Strategy

### Unit Tests

1. **WAVTranscriptionService Tests**
   - Test successful transcription
   - Test error handling scenarios
   - Test cancellation functionality

2. **File Management Tests**
   - Test WAV file creation and storage
   - Test file cleanup procedures
   - Test file metadata extraction

3. **Error Handling Tests**
   - Test each error type
   - Test recovery mechanisms
   - Test user feedback systems

### Integration Tests

1. **End-to-End Workflow**
   - Record audio → Complete → Transcribe → Update note
   - Test with various audio qualities
   - Test with different file sizes

2. **UI Integration**
   - Test loading states
   - Test error display
   - Test progress indicators

3. **Data Persistence**
   - Test note updates
   - Test widget synchronization
   - Test data consistency

### Performance Tests

1. **Transcription Speed**
   - Measure transcription time for various file sizes
   - Test memory usage during transcription
   - Test concurrent transcription scenarios

2. **File I/O Performance**
   - Test file read/write operations
   - Test storage cleanup efficiency
   - Test large file handling

## Security Considerations

### Privacy Protection

1. **Local Processing**: Prefer on-device transcription when possible
2. **Data Encryption**: Encrypt audio files at rest
3. **Temporary Files**: Secure cleanup of temporary transcription files
4. **Network Security**: Use secure connections for cloud transcription

### Permission Management

1. **Microphone Access**: Maintain existing permission handling
2. **File System Access**: Ensure proper sandboxing
3. **Network Access**: Handle network permission gracefully
4. **Speech Recognition**: Manage speech recognition permissions

## Performance Optimization

### Memory Management

1. **Streaming Processing**: Process large audio files in chunks
2. **Memory Cleanup**: Proper disposal of audio buffers
3. **Background Processing**: Use background queues for transcription

### Storage Optimization

1. **File Compression**: Compress WAV files when appropriate
2. **Cleanup Policies**: Automatic cleanup of old recordings
3. **Storage Monitoring**: Monitor available storage space

### Network Optimization

1. **Adaptive Quality**: Adjust transcription quality based on network
2. **Caching**: Cache transcription results when appropriate
3. **Offline Fallback**: Seamless offline mode switching

## Accessibility

### Visual Accessibility

1. **Loading Indicators**: Clear visual progress feedback
2. **Error Messages**: High contrast error displays
3. **Button States**: Clear visual states for Complete button

### Audio Accessibility

1. **VoiceOver Support**: Proper accessibility labels
2. **Audio Feedback**: Optional audio confirmation of transcription
3. **Haptic Feedback**: Tactile feedback for transcription completion

### Motor Accessibility

1. **Button Sizing**: Maintain adequate touch targets
2. **Gesture Alternatives**: Alternative interaction methods
3. **Timeout Handling**: Appropriate timeout values for users with disabilities