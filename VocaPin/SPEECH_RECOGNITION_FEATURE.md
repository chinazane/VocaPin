# Speech Recognition Feature

## Overview
The VocaPin app now includes a speech recognition feature that allows users to convert their voice into text for their notes.

## Features
- **60-second countdown timer** - Records for up to 60 seconds
- **Real-time audio wave visualization** - Shows voice input levels
- **Start/Stop recording** - Tap the red button to start/stop recording
- **Redo functionality** - Reset and start over with the redo button
- **Live transcription** - See recognized text in real-time
- **Integration with notes** - Recognized text is automatically added to the current note

## How to Use
1. Tap the **microphone icon** in the center of the bottom toolbar
2. The speech recognition view will appear with a dark overlay
3. Tap the **red record button** to start recording
4. Speak clearly into the microphone
5. Watch the **audio wave visualization** and **countdown timer**
6. Tap the **red stop button** to pause recording
7. Use the **redo button** (↻) to start over if needed
8. Tap the **checkmark button** (✓) to save the recognized text to your current note
9. Tap the **X button** to close without saving

## Technical Implementation

### Files Created
- `VocaPin/Views/SpeechRecognition/SpeechRecognitionView.swift` - Main speech recognition UI
- `VocaPin/Views/SpeechRecognition/AudioWaveView.swift` - Audio wave visualization component
- `VocaPin/Views/SpeechRecognition/SpeechRecognizer.swift` - Speech recognition logic

### Files Modified
- `ContentView.swift` - Added speech recognition integration
- `BottomToolbarView.swift` - Added microphone button functionality

### Permissions Required
The app requires the following permissions (to be added in Xcode project settings):
- **Microphone Usage** (`NSMicrophoneUsageDescription`)
- **Speech Recognition** (`NSSpeechRecognitionUsageDescription`)

### Dependencies
- `Speech` framework - For speech-to-text conversion
- `AVFoundation` framework - For audio recording and level monitoring

## UI Design
The speech recognition view features:
- Dark semi-transparent background
- Circular progress indicator showing remaining time
- Microphone icon in the center
- Real-time countdown display (MM:SS format)
- Audio wave visualization below the timer
- Three control buttons at the bottom:
  - Redo (left)
  - Record/Stop (center, red)
  - Done (right, green)

## Integration
The recognized text is automatically appended to the current note when the user taps the done button. If the note is empty, the recognized text becomes the note content. If the note already has content, the recognized text is added with a space separator.