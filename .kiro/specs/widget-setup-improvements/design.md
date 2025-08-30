# Design Document

## Overview

This design addresses two key issues with the current widget setup experience:
1. Ensuring the widget toggle properly triggers the WidgetSetupView presentation
2. Optimizing the WidgetSetupView to display as an appropriately sized modal popup rather than a full-screen view

The solution maintains the existing handwritten sticky note aesthetic while improving usability and presentation.

## Architecture

### Current State Analysis
- WidgetStickyNoteCard exists in ProfileSettingsView with toggle functionality
- WidgetSetupView exists as a separate full-screen view
- Navigation between toggle and setup view may not be properly connected
- WidgetSetupView is currently designed for full-screen presentation

### Proposed Changes
- Ensure proper sheet presentation from ProfileSettingsView
- Modify WidgetSetupView to work optimally as a modal popup
- Implement proper state management for toggle and modal interaction

## Components and Interfaces

### 1. ProfileSettingsView (Modified)
```swift
// Settings Section with proper sheet presentation
@State private var showWidgetSetup = false

// In SettingsSection body:
.sheet(isPresented: $showWidgetSetup) {
    WidgetSetupView()
        .presentationDetents([.height(500), .large])
        .presentationDragIndicator(.visible)
}

// In handleWidgetToggle:
private func handleWidgetToggle(enabled: Bool) {
    settingsManager.configureWidget()
    if enabled {
        showWidgetSetup = true
    }
}
```

### 2. WidgetSetupView (Redesigned for Modal)
```swift
struct WidgetSetupView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Compact header for modal
                    // Appropriately sized content
                    // Proper button sizing
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .background(Color.stickyNoteYellow)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
```

### 3. WidgetStickyNoteCard (Verified Integration)
- Ensure onToggle callback properly triggers modal presentation
- Maintain toggle state consistency
- Handle rapid toggle interactions gracefully

## Data Models

### State Management
```swift
// In ProfileSettingsView.SettingsSection
@State private var showWidgetSetup = false
@StateObject private var settingsManager = SettingsManager.shared

// Toggle handling
private func handleWidgetToggle(enabled: Bool) {
    settingsManager.configureWidget()
    
    // Only show setup when enabling (not disabling)
    if enabled {
        showWidgetSetup = true
    }
}
```

### Modal Presentation Configuration
```swift
.sheet(isPresented: $showWidgetSetup) {
    WidgetSetupView()
        .presentationDetents([.height(500), .large]) // Allow 500pt or full height
        .presentationDragIndicator(.visible)         // Show drag indicator
        .presentationCornerRadius(20)                // Rounded corners
        .presentationBackground(.regularMaterial)    // Proper background
}
```

## Error Handling

### Toggle State Management
- Prevent multiple modal presentations from rapid toggling
- Ensure toggle state persists correctly after modal dismissal
- Handle edge cases where modal is dismissed while toggle is being changed

### Modal Presentation Issues
- Handle device rotation during modal presentation
- Manage modal state during app backgrounding/foregrounding
- Ensure proper cleanup when modal is dismissed

### Accessibility Considerations
- Maintain proper focus management when modal appears/disappears
- Ensure VoiceOver can navigate modal content properly
- Provide appropriate accessibility labels for modal controls

## Testing Strategy

### Unit Tests
- Test toggle state management in isolation
- Verify modal presentation triggers correctly
- Test edge cases with rapid toggle interactions

### Integration Tests
- Test complete flow from toggle activation to modal presentation
- Verify modal dismissal returns to correct state
- Test interaction between ProfileSettingsView and WidgetSetupView

### UI Tests
- Test modal presentation and dismissal gestures
- Verify proper sizing across different device sizes
- Test accessibility navigation through modal content

### Manual Testing Scenarios
1. **Basic Flow**: Toggle ON → Modal appears → Dismiss → Toggle remains ON
2. **Rapid Toggle**: Quick ON/OFF/ON toggles → Only one modal appears
3. **Device Rotation**: Modal open → Rotate device → Modal maintains proper layout
4. **Background/Foreground**: Modal open → Background app → Return → Modal state preserved
5. **Accessibility**: Enable VoiceOver → Navigate through modal → All elements accessible

## Implementation Plan

### Phase 1: Fix Toggle Integration
1. Verify ProfileSettingsView.SettingsSection has proper sheet presentation
2. Ensure handleWidgetToggle correctly triggers showWidgetSetup state
3. Test basic toggle → modal flow

### Phase 2: Optimize Modal Presentation
1. Add presentationDetents to control modal sizing
2. Add presentationDragIndicator for better UX
3. Configure proper background and corner radius

### Phase 3: Redesign WidgetSetupView Layout
1. Adjust spacing and padding for modal context
2. Optimize font sizes for smaller presentation area
3. Ensure "Got it!" button is properly positioned

### Phase 4: Polish and Testing
1. Handle edge cases and error scenarios
2. Add accessibility improvements
3. Comprehensive testing across devices and orientations

## Design Decisions

### Modal Size Strategy
- Use `.height(500)` as primary detent for optimal content display
- Allow `.large` as secondary option for users who prefer full-screen
- This provides flexibility while defaulting to appropriate size

### Content Optimization
- Reduce excessive spacing that works for full-screen but not modal
- Maintain handwritten aesthetic while ensuring readability
- Keep essential information visible without scrolling when possible

### Interaction Patterns
- Maintain iOS standard modal dismissal gestures (swipe down, tap outside)
- Provide explicit "Done" button for clear completion action
- Ensure toggle state is preserved regardless of dismissal method