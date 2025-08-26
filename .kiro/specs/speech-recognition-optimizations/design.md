# Design Document

## Overview

This design document outlines the technical approach for implementing speech recognition optimizations in the VocaPin app. The solution enhances the existing speech recognition system with real-time audio visualization, progress tracking, audio file recording, and comprehensive logging capabilities.

## Architecture

The optimization builds upon the existing three-component architecture:
- **SpeechRecognitionView**: Enhanced UI with improved progress indication
- **AudioWaveView**: Upgraded with real-time audio level processing
- **SpeechRecognizer**: Extended with audio recording and enhanced logging capabilities

### Key Architectural Changes

1. **Audio Pipeline Enhancement**: Modify the existing audio tap to capture both recognition data and raw audio for file recording
2. **Real-time Processing**: Implement more sophisticated audio level calculation for accurate waveform visualization
3. **File Management**: Add audio file recording capabilities with proper file naming and storage management
4. **Progress Tracking**: Enhance the existing timer system with visual progress indication

## Components and Interfaces

### Enhanced SpeechRecognizer Class

```swift
class SpeechRecognizer: ObservableObject {
    // Existing properties
    @Published var audioLevel: Float = 0.0
    
    // New properties for recording
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    @Published var isRecordingAudio: Bool = false
    
    // Enhanced methods
    func startRecording(completion: @escaping (String) -> Void)
    func stopRecording()
    private func setupAudioRecording() -> URL?
    private func startAudioFileRecording()
    private func stopAudioFileRecording()
    private func updateAudioLevel(from buffer: AVAudioPCMBuffer)
    private func logRecordingPath(_ url: URL)
}
```

### Enhanced AudioWaveView

```swift
struct AudioWaveView: View {
    let isRecording: Bool
    let audioLevel: Float
    
    // Enhanced wave calculation
    private func updateWaveHeights()
    private func calculateRealtimeWaveform(audioLevel: Float) -> [CGFloat]
}
```

### Enhanced SpeechRecognitionView

```swift
struct SpeechRecognitionView: View {
    // Existing properties
    @State private var timeRemaining: Int = 60
    @State private var totalTime: Int = 60
    
    // Enhanced progress calculation
    private var progressPercentage: Double {
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }
}
```

## Data Models

### Audio Recording Configuration

```swift
struct AudioRecordingConfig {
    static let sampleRate: Double = 44100.0
    static let channels: Int = 1
    static let bitDepth: Int = 16
    static let fileFormat: AudioFileTypeID = kAudioFileWAVEType
    
    static var settings: [String: Any] {
        return [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channels,
            AVLinearPCMBitDepthKey: bitDepth,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
    }
}
```

### File Naming Strategy

```swift
struct AudioFileNaming {
    static func generateFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return "VocaPin_Recording_\(formatter.string(from: Date())).wav"
    }
    
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
```

## Error Handling

### Audio Recording Errors

1. **Permission Denied**: Handle microphone access denial gracefully
2. **Storage Full**: Manage insufficient storage space scenarios
3. **File Creation Failed**: Handle file system errors during recording setup
4. **Recording Interrupted**: Manage system interruptions (calls, other apps)

### Error Recovery Strategies

```swift
enum AudioRecordingError: Error {
    case permissionDenied
    case fileCreationFailed
    case recordingInterrupted
    case insufficientStorage
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return "Microphone access required for recording"
        case .fileCreationFailed:
            return "Unable to create recording file"
        case .recordingInterrupted:
            return "Recording was interrupted"
        case .insufficientStorage:
            return "Insufficient storage space for recording"
        }
    }
}
```

## Testing Strategy

### Unit Testing

1. **Audio Level Calculation**: Test RMS calculation accuracy with known audio samples
2. **File Naming**: Verify unique filename generation and collision handling
3. **Progress Calculation**: Test timer and progress percentage calculations
4. **Error Handling**: Test all error scenarios with mocked failures

### Integration Testing

1. **Audio Pipeline**: Test simultaneous speech recognition and file recording
2. **UI Updates**: Verify real-time updates of waveform and progress indicators
3. **File System**: Test file creation, writing, and cleanup operations
4. **Permission Handling**: Test various permission states and user responses

### Performance Testing

1. **Memory Usage**: Monitor memory consumption during extended recording sessions
2. **CPU Usage**: Measure impact of real-time audio processing on device performance
3. **Battery Impact**: Assess battery drain from continuous audio processing
4. **File Size**: Monitor WAV file sizes and storage impact

### Manual Testing Scenarios

1. **Voice Variation Testing**: Test with different voice volumes, pitches, and speaking patterns
2. **Timeout Testing**: Verify behavior when recording reaches time limits
3. **Interruption Testing**: Test behavior during phone calls, app switching, and system notifications
4. **Storage Testing**: Test behavior with low storage conditions

## Implementation Considerations

### Real-time Audio Processing

- Use efficient RMS calculation to minimize CPU impact
- Implement smoothing algorithms to prevent jittery waveform animations
- Balance update frequency with performance requirements

### File Management

- Implement automatic cleanup of old recording files to manage storage
- Use atomic file operations to prevent corruption during recording
- Consider compression options for long recordings

### User Experience

- Provide visual feedback for all recording states
- Ensure smooth animations that don't interfere with speech recognition
- Implement graceful degradation when features are unavailable

### Platform Considerations

- Leverage iOS-specific audio frameworks for optimal performance
- Handle different device capabilities (older devices, different microphones)
- Consider accessibility requirements for visual indicators