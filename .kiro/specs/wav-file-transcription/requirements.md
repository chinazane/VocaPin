# Requirements Document

## Introduction

This specification defines a new feature for the VocaPin app that enables users to transcribe recorded WAV audio files and replace sticky note text with the transcription. Currently, the app supports real-time speech recognition during recording, but users need the ability to transcribe the saved WAV files after recording is complete.

## Requirements

### Requirement 1

**User Story:** As a VocaPin user, I want to transcribe my recorded WAV audio file after completing a voice recording, so that I can convert my saved audio into text for my sticky notes.

#### Acceptance Criteria

1. WHEN the user completes a voice recording session THEN the system SHALL save a WAV audio file to local storage
2. WHEN the user taps the green Complete button (checkmark) in the Speaking View THEN the system SHALL initiate transcription of the recorded WAV file
3. WHEN transcription is initiated THEN the system SHALL display a loading indicator with "Transcribing..." message
4. WHEN transcription completes successfully THEN the system SHALL replace the current sticky note's text with the transcription result
5. WHEN transcription fails THEN the system SHALL display an error message and retain any existing real-time transcription text

### Requirement 2

**User Story:** As a VocaPin user, I want clear visual feedback during the transcription process, so that I understand the system is processing my audio file.

#### Acceptance Criteria

1. WHEN transcription begins THEN the system SHALL show a loading spinner or progress indicator
2. WHEN transcription is in progress THEN the system SHALL display "Transcribing audio file..." status message
3. WHEN transcription completes THEN the system SHALL show a brief success confirmation before closing the Speaking View
4. WHEN transcription takes longer than expected THEN the system SHALL show progress updates or estimated time remaining
5. IF transcription exceeds 30 seconds THEN the system SHALL provide option to cancel the operation

### Requirement 3

**User Story:** As a VocaPin user, I want the transcription to handle different audio quality levels gracefully, so that I get the best possible text output from my recordings.

#### Acceptance Criteria

1. WHEN the WAV file has good audio quality THEN the system SHALL produce accurate transcription with minimal errors
2. WHEN the WAV file has poor audio quality THEN the system SHALL attempt transcription and provide best-effort results
3. WHEN the WAV file is corrupted or unreadable THEN the system SHALL display appropriate error message
4. WHEN the WAV file is too short (less than 1 second) THEN the system SHALL display "Recording too short to transcribe" message
5. WHEN the WAV file is too long (over 60 seconds) THEN the system SHALL transcribe the entire file but warn about processing time

### Requirement 4

**User Story:** As a VocaPin user, I want the transcription feature to work offline when possible, so that I can use the feature without internet connectivity.

#### Acceptance Criteria

1. WHEN device has internet connectivity THEN the system SHALL use cloud-based speech recognition for optimal accuracy
2. WHEN device lacks internet connectivity THEN the system SHALL use on-device speech recognition if available
3. WHEN neither cloud nor on-device recognition is available THEN the system SHALL display appropriate error message
4. WHEN switching between online/offline modes THEN the system SHALL maintain consistent user experience
5. WHEN using offline mode THEN the system SHALL inform user about potentially reduced accuracy

### Requirement 5

**User Story:** As a VocaPin user, I want the transcription to integrate seamlessly with the existing note management system, so that my workflow remains smooth and intuitive.

#### Acceptance Criteria

1. WHEN transcription completes successfully THEN the system SHALL update the current sticky note's text immediately
2. WHEN the sticky note already contains text THEN the system SHALL replace the existing text with the new transcription
3. WHEN transcription is applied THEN the system SHALL save the updated note to persistent storage
4. WHEN transcription is applied THEN the system SHALL sync the updated note to the widget system
5. WHEN the Speaking View closes after transcription THEN the system SHALL return to the main notes view showing the updated note

### Requirement 6

**User Story:** As a VocaPin user, I want proper error handling and recovery options, so that I can resolve issues and successfully transcribe my audio.

#### Acceptance Criteria

1. WHEN transcription fails due to network issues THEN the system SHALL offer retry option
2. WHEN transcription fails due to audio format issues THEN the system SHALL display specific error message
3. WHEN transcription fails due to permissions THEN the system SHALL guide user to grant necessary permissions
4. WHEN transcription is cancelled by user THEN the system SHALL retain any existing real-time transcription text
5. WHEN multiple transcription attempts fail THEN the system SHALL offer option to save audio file for later processing