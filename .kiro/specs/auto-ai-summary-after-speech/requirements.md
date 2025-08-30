# Requirements Document

## Introduction

This feature automatically triggers AI summarization after speech recognition completion in the note editing view. When users complete speech recognition, the system will automatically process the transcribed text through AI summarization and display the summarized content in the sticky note, creating a seamless voice-to-summary workflow.

## Requirements

### Requirement 1

**User Story:** As a user who uses speech recognition, I want the transcribed text to be automatically summarized by AI, so that I can get concise, processed content without manual intervention.

#### Acceptance Criteria

1. WHEN speech recognition completes successfully THEN the system SHALL automatically trigger AI summarization of the transcribed text
2. WHEN AI summarization is processing THEN the system SHALL show a loading indicator on the note
3. WHEN AI summarization completes successfully THEN the system SHALL replace the raw transcript with the AI-summarized content in the note
4. WHEN AI summarization fails THEN the system SHALL keep the original transcribed text and show an error message

### Requirement 2

**User Story:** As a user, I want to see the AI processing status during automatic summarization, so that I understand what's happening and can wait appropriately.

#### Acceptance Criteria

1. WHEN automatic AI summarization starts THEN the system SHALL display a processing indicator with text "Summarizing with AI..."
2. WHEN AI processing is active THEN the system SHALL disable other actions to prevent conflicts
3. WHEN AI processing completes THEN the system SHALL remove the processing indicator
4. WHEN AI processing takes longer than expected THEN the system SHALL provide appropriate feedback

### Requirement 3

**User Story:** As a user, I want the AI summarization to work seamlessly with the existing AI summary functionality, so that the feature is consistent and reliable.

#### Acceptance Criteria

1. WHEN automatic AI summarization is triggered THEN the system SHALL use the same AI service and processing logic as the manual AI summary button
2. WHEN automatic AI summarization is active THEN the system SHALL disable the manual AI summary button to prevent conflicts
3. WHEN automatic AI summarization completes THEN the system SHALL re-enable the manual AI summary button
4. WHEN the note content is updated with AI summary THEN the system SHALL sync with widgets immediately

### Requirement 4

**User Story:** As a user, I want control over the automatic AI summarization process, so that I can handle errors or cancel if needed.

#### Acceptance Criteria

1. WHEN automatic AI summarization fails THEN the system SHALL display an error dialog with options to "Retry" or "Keep Original Text"
2. WHEN the user chooses "Retry" THEN the system SHALL attempt AI summarization again
3. WHEN the user chooses "Keep Original Text" THEN the system SHALL keep the transcribed text without summarization
4. WHEN AI summarization is processing THEN the system SHALL provide a way to cancel the operation

### Requirement 5

**User Story:** As a user, I want the automatic AI summarization to handle different types of speech content appropriately, so that the feature works well for various use cases.

#### Acceptance Criteria

1. WHEN the transcribed text is very short (less than 10 words) THEN the system SHALL skip AI summarization and keep the original text
2. WHEN the transcribed text is empty or only whitespace THEN the system SHALL not trigger AI summarization
3. WHEN the transcribed text contains mixed languages THEN the system SHALL handle AI summarization appropriately
4. WHEN the transcribed text is already concise THEN the system SHALL still process it through AI for consistency and potential improvements