# Design Document

## Overview

This design document outlines the implementation of three action buttons (Speaker, Delete, Edit) in the footer of the NotebookEditingView. The design leverages existing UI patterns from BottomToolbarView and integrates seamlessly with current speech recognition and deletion workflows while adding new editing mode functionality.

## Architecture

### Component Structure

```
NotebookEditingView
├── Navigation Bar (existing)
├── AI Summary Toolbar (existing)  
├── Sticky Note Content (existing)
└── Footer Action Buttons (NEW)
    ├── SpeechRecognitionButton
    ├── DeleteNoteButton
    └── EditModeButton
```

### State Management

The footer buttons will be managed through the existing NotebookEditingView state system:

- `@State private var showSpeechRecognition: Bool = false` - Controls speech recognition modal
- `@State private var showDeleteConfirmation: Bool = false` - Controls delete confirmation dialog
- `@FocusState private var isTextEditorFocused: Bool` - Existing focus state for edit functionality

### Integration Points

1. **Speech Recognition**: Reuses existing `SpeechRecognitionView` component
2. **Delete Functionality**: Adapts existing `DeleteNoteView` for in-editing context
3. **Edit Mode**: Leverages existing `@FocusState` and TextEditor focus management

## Components and Interfaces

### FooterActionButtonsView

A new reusable component that encapsulates the three action buttons:

```swift
struct FooterActionButtonsView: View {
    @Binding var showSpeechRecognition: Bool
    @Binding var showDeleteConfirmation: Bool
    @Binding var isTextEditorFocused: Bool
    
    var body: some View {
        // Implementation details in tasks
    }
}
```

### Button Specifications

#### Speaker Button
- **Icon**: `mic.fill` (SF Symbol)
- **Background**: Yellow/Gold circular button (70pt diameter)
- **Action**: Opens speech recognition modal
- **State**: Disabled during active recording

#### Delete Button  
- **Icon**: `trash` (SF Symbol)
- **Background**: Gray circular button (60pt diameter)
- **Action**: Shows delete confirmation dialog
- **Behavior**: Clears note content (not deletion from collection)

#### Edit Button
- **Icon**: `pencil` (SF Symbol) 
- **Background**: Gray circular button (60pt diameter)
- **Action**: Activates text editor focus and keyboard
- **State**: Visual indication when in edit mode

### Layout Design

```
[Delete]    [Speaker]    [Edit]
   60pt       70pt       60pt
    ↑          ↑          ↑
  Gray      Yellow      Gray
```

- **Spacing**: 60pt between button centers
- **Alignment**: Horizontally centered
- **Padding**: 40pt horizontal, 30pt bottom
- **Background**: Cork board color matching existing design

## Data Models

### Enhanced Note Interaction

The existing `Note` model requires no modifications. All interactions work with the current structure:

```swift
struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String        // Modified by speech input and delete action
    var position: CGPoint   // Unchanged
    var rotation: Double    // Unchanged  
    var color: Color        // Unchanged
}
```

### Speech Integration Data Flow

```
User taps Speaker → SpeechRecognitionView → Transcribed text → Append to note.text
```

### Delete Integration Data Flow

```
User taps Delete → Confirmation dialog → Clear note.text → Update UI
```

## Error Handling

### Speech Recognition Errors
- Reuse existing error handling from `SpeechRecognitionView`
- Display errors in modal context without affecting editing view
- Fallback to manual text input on speech failure

### Delete Operation Errors
- No complex error scenarios (simple text clearing)
- Confirmation dialog prevents accidental deletion
- Immediate UI feedback for successful clearing

### Edit Mode Errors
- Handle keyboard presentation failures gracefully
- Maintain focus state consistency
- Provide visual feedback for focus changes

## Testing Strategy

### Unit Tests
1. **FooterActionButtonsView Tests**
   - Button tap actions trigger correct state changes
   - Proper button styling and accessibility
   - Correct icon and color assignments

2. **Integration Tests**
   - Speech recognition integration with note text appending
   - Delete confirmation flow and text clearing
   - Edit mode activation and keyboard presentation

3. **State Management Tests**
   - Focus state transitions work correctly
   - Modal presentation/dismissal state handling
   - Note content updates propagate correctly

### UI Tests
1. **Button Interaction Tests**
   - All three buttons are tappable and responsive
   - Visual feedback appears on button press
   - Correct modals/actions are triggered

2. **Accessibility Tests**
   - Buttons meet minimum touch target size (44pt)
   - VoiceOver labels are descriptive and accurate
   - Keyboard navigation works properly

3. **Layout Tests**
   - Footer maintains proper spacing across device sizes
   - Buttons remain accessible when keyboard is visible
   - Layout adapts correctly to orientation changes

### Integration Tests
1. **Speech-to-Text Flow**
   - Complete speech recognition workflow from button tap to text insertion
   - Error handling and recovery scenarios
   - Text appending vs replacement behavior

2. **Delete Confirmation Flow**
   - Full delete confirmation workflow
   - Cancel and confirm actions work correctly
   - Note state updates and widget synchronization

3. **Edit Mode Flow**
   - Edit button activates text editor focus
   - Keyboard appears and disappears correctly
   - Text selection and editing capabilities work

## Performance Considerations

### Rendering Optimization
- Footer buttons use lightweight SF Symbols
- Minimal state changes to prevent unnecessary re-renders
- Efficient button press animations

### Memory Management
- Reuse existing modal components (SpeechRecognitionView, DeleteNoteView)
- No additional heavy resources required
- Proper cleanup of focus states and timers

### Responsiveness
- Immediate visual feedback on button press
- Smooth transitions between states
- Non-blocking UI operations for all actions

## Accessibility

### VoiceOver Support
- Speaker button: "Voice input, button"
- Delete button: "Clear note content, button" 
- Edit button: "Edit note, button"

### Touch Targets
- All buttons meet 44pt minimum touch target
- Adequate spacing prevents accidental taps
- Clear visual distinction between buttons

### Keyboard Navigation
- Support for external keyboard navigation
- Proper focus management and indication
- Logical tab order through interface elements

## Visual Design Integration

### Color Scheme
- Maintains existing cork board background (#E6D9CC)
- Yellow speaker button matches existing microphone styling
- Gray buttons use consistent app gray palette
- White icons provide sufficient contrast

### Typography
- Uses SF Symbols for consistent icon styling
- Maintains existing font hierarchy
- No additional text elements in footer

### Animations
- Subtle scale animation on button press (0.95x scale)
- Smooth transitions for modal presentations
- Consistent with existing app animation timing

### Shadow and Depth
- Consistent shadow styling with existing buttons
- Maintains visual hierarchy and depth perception
- Subtle shadows for tactile button appearance