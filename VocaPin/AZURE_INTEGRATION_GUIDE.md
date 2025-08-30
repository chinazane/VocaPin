# Azure Speech Service Integration Guide

## Overview

VocaPin now uses Azure Speech Service instead of Apple's Speech Recognition for transcribing audio recordings. This provides more consistent results and works across different languages and regions.

## What Changed

### Before (Apple Speech Recognition)
- Used Apple's on-device Speech Recognition framework
- Required Speech Recognition permissions
- Limited to device-supported languages
- Processed audio in real-time during recording

### After (Azure Speech Service)
- Uses Azure OpenAI's speech transcription service
- Only requires microphone permissions
- Supports multiple languages and better accuracy
- Records audio first, then processes with Azure

## Key Components

### 1. AzureSpeechService.swift
- Core service for communicating with Azure Speech API
- Handles file upload and transcription
- Includes error handling and retry logic

### 2. AzureSpeechRecognizer.swift
- Replaces the original SpeechRecognizer
- Records audio to WAV files
- Processes recordings with Azure after recording stops
- Maintains audio visualization during recording

### 3. AzureWAVTranscriptionService.swift
- Handles WAV file transcription using Azure
- Provides progress updates and error handling
- Maps Azure errors to user-friendly messages

## How It Works

1. **Recording Phase**
   - User taps record button
   - App records audio to WAV file
   - Audio visualization shows real-time levels
   - No transcription happens during recording

2. **Processing Phase**
   - When user stops recording, WAV file is sent to Azure
   - Azure Speech Service transcribes the audio
   - Transcribed text is returned and displayed
   - Text is added to the current sticky note

## Configuration

The Azure configuration is in `AzureSpeechConfig`:

```swift
struct AzureSpeechConfig {
    let endpoint: String = "https://china-mel64ynr-eastus2.cognitiveservices.azure.com"
    let transcribeDeployment: String = "gpt-4o-mini-transcribe"
    let chatDeployment: String = "gpt-4o-mini"
    let apiVersion: String = "2025-03-01-preview"
    let apiKey: String = "your-api-key-here"
}
```

## Supported Audio Formats

- WAV (primary format used by the app)
- MP3
- M4A
- AAC
- FLAC

## Error Handling

The integration includes comprehensive error handling for:

- Network connectivity issues
- Invalid API keys or endpoints
- Unsupported file formats
- Audio files that are too short or too long
- Azure service errors

## Testing

Use `AzureIntegrationTest.swift` to verify the integration:

1. Run basic configuration tests
2. Test with sample audio files
3. Verify network connectivity
4. Check error handling

## User Experience Changes

### Visual Indicators
- "Powered by Azure Speech" label in the speaking view
- Progress messages show "Processing with Azure..."
- Error messages are Azure-specific

### Workflow Changes
- Recording must complete before transcription begins
- Slight delay while audio is processed by Azure
- More accurate transcription results
- Better handling of background noise

## Troubleshooting

### Common Issues

1. **Network Errors**
   - Check internet connection
   - Verify Azure endpoint is accessible

2. **API Key Issues**
   - Ensure API key is valid and not expired
   - Check Azure subscription status

3. **Audio Quality Issues**
   - Record in quiet environments
   - Ensure microphone permissions are granted
   - Check audio file isn't corrupted

4. **Transcription Failures**
   - Try shorter recordings (under 2 minutes)
   - Speak clearly and at normal pace
   - Ensure audio contains speech (not just silence)

### Debug Information

The app logs detailed information about:
- Recording setup and status
- File creation and validation
- Azure API requests and responses
- Error conditions and recovery attempts

## Performance Considerations

- Audio files are temporarily stored locally
- Files are automatically cleaned up after processing
- Network usage depends on audio file size
- Processing time varies with audio length and network speed

## Privacy and Security

- Audio files are sent to Azure for processing
- Files are deleted locally after transcription
- Azure processes audio according to their privacy policy
- No audio data is permanently stored by the app

## Future Enhancements

Potential improvements:
- Real-time streaming transcription
- Multiple language support
- Custom vocabulary for better accuracy
- Offline fallback using Apple Speech Recognition