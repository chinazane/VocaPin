# Design Document

## Overview

This design document outlines the implementation of automatic AI summarization after speech recognition completion. The feature integrates seamlessly with the existing AI summary functionality and speech recognition workflow, providing users with a streamlined voice-to-summary experience.

## Architecture

### Component Integration

```
Speech Recognition Flow:
SpeechRecognitionView → Transcribed Text → NotebookEditingView → Auto AI Summary → Summarized Content

Existing AI Summary Flow:
Manual Button → AI Summary → Display Result

New Integrated Flow:
Speech Recognition → Auto Trigger → Shared AI Logic → Display Result
```

### State Management Enhancement

The existing NotebookEditingView will be enhanced with additional state for automatic AI processing:

```swift
// Existing AI Summary states
@State private var isProcessingAI = false
@State private var aiSummaryError: String?
@State private var showingAIError = false

// New automatic AI states
@State private var isAutoProcessingAI = false
@State private var autoAIError: String?
@State private var showingAutoAIError = false
```

### Service Architecture

The existing `AzureChatGPT4OService` will be refactored to support both manual and automatic invocation:

```swift
// Current private method becomes public
public func generateAISummary(for text: String) async throws -> String

// Enhanced error handling for automatic context
public enum AISummaryError: Error {
    case textTooShort
    case networkError(String)
    case processingError(String)
}
```

## Components and Interfaces

### Enhanced NotebookEditingView

The main editing view will be enhanced to handle automatic AI summarization:

```swift
struct NotebookEditingView: View {
    // Existing properties...
    
    // New automatic AI processing states
    @State private var isAutoProcessingAI = false
    @State private var pendingTranscript: String?
    
    // Enhanced speech recognition completion handler
    private func handleSpeechRecognitionCompletion(_ recognizedText: String) {
        // Add text to editor
        // Trigger automatic AI summarization
    }
    
    // Refactored AI summary logic
    private func processWithAI(_ text: String, isAutomatic: Bool = false) async {
        // Shared AI processing logic
    }
}
```

### AI Service Enhancement

The existing AI service will be enhanced to support the new workflow:

```swift
class AzureChatGPT4OService {
    // Enhanced public interface
    func generateSummary(for text: String) async throws -> String {
        // Existing logic made public and enhanced
    }
    
    // Text validation for automatic processing
    func shouldAutoSummarize(_ text: String) -> Bool {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }
}
```

### UI State Indicators

Enhanced UI indicators for automatic processing:

```swift
// Enhanced status indicator logic
private var aiStatusText: String {
    if isAutoProcessingAI {
        return "Auto-summarizing with AI..."
    } else if isProcessingAI {
        return "Processing with AI..."
    } else if !editingText.isEmpty {
        return "Ready for AI processing"
    } else {
        return "Enter text to summarize"
    }
}

private var aiStatusColor: Color {
    if isAutoProcessingAI || isProcessingAI {
        return .orange
    } else if !editingText.isEmpty {
        return .green
    } else {
        return .secondary
    }
}
```

## Data Flow

### Automatic AI Summarization Flow

```
1. User completes speech recognition
   ↓
2. SpeechRecognitionView calls onTextRecognized(transcribedText)
   ↓
3. NotebookEditingView receives transcribed text
   ↓
4. System validates text length (>= 10 words)
   ↓
5. System adds raw transcript to editingText
   ↓
6. System triggers automatic AI summarization
   ↓
7. AI service processes the text
   ↓
8. System replaces raw transcript with AI summary
   ↓
9. Widget sync occurs with final content
```

### Error Handling Flow

```
AI Processing Error
   ↓
Show Error Dialog with Options:
- Retry: Attempt AI summarization again
- Keep Original: Use transcribed text as-is
   ↓
User Selection
   ↓
Execute chosen action
```

### State Synchronization

```swift
// Prevent conflicts between manual and automatic AI processing
private var canProcessAI: Bool {
    return !isProcessingAI && !isAutoProcessingAI
}

// Enhanced button state management
private var aiButtonDisabled: Bool {
    return isProcessingAI || 
           isAutoProcessingAI || 
           editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}
```

## Error Handling

### Automatic AI Processing Errors

1. **Network Errors**: Show retry dialog with option to keep original text
2. **Processing Errors**: Display error message and fallback to original transcript
3. **Timeout Errors**: Cancel automatic processing and keep original text
4. **Service Unavailable**: Skip automatic processing gracefully

### Error Recovery Strategies

```swift
private func handleAutoAIError(_ error: Error) {
    autoAIError = error.localizedDescription
    showingAutoAIError = true
    isAutoProcessingAI = false
    
    // Keep original transcript as fallback
    // User can manually retry if desired
}
```

## Testing Strategy

### Unit Tests

1. **AI Service Tests**
   - Test public `generateSummary` method
   - Test text validation logic (`shouldAutoSummarize`)
   - Test error handling for different scenarios

2. **State Management Tests**
   - Test automatic AI trigger after speech recognition
   - Test conflict prevention between manual and automatic AI
   - Test error state handling and recovery

3. **Integration Tests**
   - Test complete speech-to-summary workflow
   - Test error scenarios and user choices
   - Test widget synchronization after AI processing

### UI Tests

1. **Automatic Processing Flow**
   - Complete speech recognition and verify AI auto-trigger
   - Verify loading indicators during automatic processing
   - Test final content display after AI summarization

2. **Error Handling UI**
   - Test error dialog appearance and options
   - Test retry functionality from error dialog
   - Test "keep original" functionality

3. **State Consistency**
   - Test button states during automatic processing
   - Test prevention of manual AI during automatic processing
   - Test UI updates after automatic processing completion

## Performance Considerations

### Processing Optimization

- **Debouncing**: Prevent multiple automatic AI calls if speech recognition is triggered rapidly
- **Caching**: Consider caching AI results for identical transcripts
- **Background Processing**: Ensure AI processing doesn't block UI interactions

### Memory Management

- **Service Reuse**: Use existing AI service instance to prevent memory overhead
- **State Cleanup**: Properly clean up automatic processing states
- **Error State Management**: Prevent memory leaks from error handling

### User Experience

- **Immediate Feedback**: Show processing indicators immediately
- **Graceful Degradation**: Fall back to original transcript on any issues
- **Non-blocking**: Allow other actions while AI processing occurs (where safe)

## Security and Privacy

### Data Handling

- **Transcript Security**: Ensure transcribed text is handled securely during AI processing
- **Error Logging**: Avoid logging sensitive transcript content in error messages
- **Service Communication**: Maintain existing security protocols for AI service calls

### User Control

- **Opt-out Capability**: Users can choose to keep original text instead of AI summary
- **Transparency**: Clear indicators show when automatic AI processing is occurring
- **Data Retention**: Follow existing patterns for AI-processed content storage

## Accessibility

### Screen Reader Support

- **Status Announcements**: Announce automatic AI processing status changes
- **Error Communication**: Ensure error dialogs are properly announced
- **Progress Indication**: Provide accessible progress feedback

### Keyboard Navigation

- **Error Dialog Navigation**: Ensure error dialogs support keyboard navigation
- **Focus Management**: Maintain proper focus during automatic processing
- **Action Accessibility**: All retry/cancel actions must be keyboard accessible

## Visual Design Integration

### Loading States

- **Processing Indicator**: Consistent with existing AI summary loading design
- **Status Text**: Enhanced status messages for automatic processing
- **Button States**: Visual indication when automatic processing prevents manual actions

### Error Presentation

- **Error Dialogs**: Consistent with existing app error dialog styling
- **Inline Errors**: Subtle error indicators that don't disrupt workflow
- **Recovery Actions**: Clear, accessible action buttons for error recovery