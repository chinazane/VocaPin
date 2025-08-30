# Requirements Document

## Introduction

This feature improves the widget setup experience in the VocaPin app by ensuring proper navigation flow when users interact with the widget toggle and optimizing the WidgetSetupView presentation as an appropriately sized popup window. The improvements focus on user experience consistency and proper modal presentation.

## Requirements

### Requirement 1

**User Story:** As a user, I want the widget toggle to show setup guidance when I enable it, so that I can easily understand how to add the widget to my home screen.

#### Acceptance Criteria

1. WHEN the user taps the widget toggle to enable it THEN the system SHALL immediately present the WidgetSetupView as a modal popup
2. WHEN the widget toggle is turned ON THEN the system SHALL save the widget preference setting
3. WHEN the WidgetSetupView is presented THEN the system SHALL display step-by-step instructions for adding the widget
4. WHEN the user dismisses the WidgetSetupView THEN the system SHALL return to the profile settings page with the toggle remaining in the ON state
5. WHEN the user turns the widget toggle OFF THEN the system SHALL NOT show the setup guidance

### Requirement 2

**User Story:** As a user, I want the widget setup guidance to appear as a properly sized popup, so that it doesn't overwhelm the interface and feels natural to interact with.

#### Acceptance Criteria

1. WHEN the WidgetSetupView is presented THEN the system SHALL display it as a modal sheet that covers approximately 70-80% of the screen height
2. WHEN the WidgetSetupView is displayed THEN the system SHALL allow the user to dismiss it by swiping down or tapping outside the modal area
3. WHEN the WidgetSetupView is presented THEN the system SHALL use appropriate padding and margins to ensure content is not cramped
4. WHEN the WidgetSetupView is displayed THEN the system SHALL maintain the handwritten sticky note aesthetic with proper font sizing
5. WHEN the modal is presented THEN the system SHALL dim the background content to focus attention on the setup instructions

### Requirement 3

**User Story:** As a user, I want the widget setup instructions to be clearly readable and well-formatted, so that I can easily follow the steps.

#### Acceptance Criteria

1. WHEN the WidgetSetupView is displayed THEN the system SHALL show the title "Widget Setup!" in large, handwritten-style font
2. WHEN the setup instructions are shown THEN the system SHALL display the subtitle "Just a few steps to get your widget on the home screen:" in readable size
3. WHEN the step list is displayed THEN the system SHALL show each step (1-5) with proper spacing and alignment
4. WHEN the steps are shown THEN the system SHALL use consistent font sizing that is neither too large nor too small for the modal size
5. WHEN the "Got it!" button is displayed THEN the system SHALL make it clearly tappable and properly sized for the modal

### Requirement 4

**User Story:** As a user, I want the widget setup modal to have proper navigation controls, so that I can easily dismiss it when I'm done reading.

#### Acceptance Criteria

1. WHEN the WidgetSetupView is presented THEN the system SHALL provide a clear "Got it!" button at the bottom
2. WHEN the user taps "Got it!" THEN the system SHALL dismiss the modal and return to the profile settings
3. WHEN the user swipes down on the modal THEN the system SHALL dismiss the WidgetSetupView
4. WHEN the modal is dismissed THEN the system SHALL maintain the widget toggle in its current state (ON if enabled)
5. WHEN the modal is dismissed THEN the system SHALL not reset any user preferences

### Requirement 5

**User Story:** As a user, I want the widget setup experience to be consistent with the app's design language, so that it feels integrated with the overall app experience.

#### Acceptance Criteria

1. WHEN the WidgetSetupView is displayed THEN the system SHALL use the same cream/yellow background color as the sticky note theme
2. WHEN the modal is presented THEN the system SHALL use rounded corners consistent with other modal presentations in the app
3. WHEN text is displayed THEN the system SHALL use the "Marker Felt" font family to maintain the handwritten aesthetic
4. WHEN the modal background is shown THEN the system SHALL use appropriate opacity to dim the underlying content
5. WHEN animations occur THEN the system SHALL use smooth transitions consistent with iOS design guidelines

### Requirement 6

**User Story:** As a user, I want the widget functionality to work reliably across different interaction patterns, so that I have a consistent experience regardless of how I interact with the toggle.

#### Acceptance Criteria

1. WHEN the user rapidly toggles the widget switch multiple times THEN the system SHALL handle each toggle appropriately without showing multiple modals
2. WHEN the WidgetSetupView is already presented AND the user toggles the switch THEN the system SHALL not present additional modals
3. WHEN the app is backgrounded while the modal is open THEN the system SHALL maintain the modal state when returning to foreground
4. WHEN the user rotates the device THEN the system SHALL maintain proper modal sizing and layout
5. WHEN accessibility features are enabled THEN the system SHALL provide proper voice-over support for all modal elements