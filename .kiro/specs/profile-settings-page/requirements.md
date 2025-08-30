# Requirements Document

## Introduction

This feature adds a comprehensive profile settings page to the VocaPin app that allows users to configure app preferences, manage widgets, access support resources, and view app information. The settings page will maintain consistency with the existing app's warm, cork board aesthetic while providing intuitive navigation and clear visual hierarchy.

## Requirements

### Requirement 1

**User Story:** As a user, I want to access a profile settings page from the main app interface, so that I can configure my app preferences and access support resources.

#### Acceptance Criteria

1. WHEN the user taps the settings gear icon in the header THEN the system SHALL navigate to the profile settings page
2. WHEN the profile settings page loads THEN the system SHALL display the app logo, title "Vocal Sticky", and tagline "Speak it. Stick it."
3. WHEN the profile settings page is displayed THEN the system SHALL use the same background color and styling as the rest of the app

### Requirement 2

**User Story:** As a user, I want to see a premium upgrade section, so that I can understand available premium features and upgrade if desired.

#### Acceptance Criteria

1. WHEN the profile settings page loads THEN the system SHALL display a prominent "Unlock Premium" section at the top
2. WHEN the premium section is displayed THEN the system SHALL show "Unlimited notes & exclusive features" as the description
3. WHEN the premium section is displayed THEN the system SHALL include an "Upgrade" button with yellow/orange styling consistent with the app theme
4. WHEN the premium section is displayed THEN the system SHALL use a yellow/orange gradient background with a lock icon

### Requirement 3

**User Story:** As a user, I want to configure widget settings, so that I can enable or disable the homepage widget for quick access.

#### Acceptance Criteria

1. WHEN the profile settings page loads THEN the system SHALL display an "Add Homepage Widget" row with a widget grid icon
2. WHEN the widget row is displayed THEN the system SHALL show "Quick access from your home screen." as the subtitle
3. WHEN the widget row is displayed THEN the system SHALL include a toggle switch that can be turned ON or OFF
4. WHEN the user taps the toggle switch THEN the system SHALL save the widget preference setting
5. WHEN the widget setting is enabled THEN the system SHALL provide guidance for adding the widget to the home screen

### Requirement 4

**User Story:** As a user, I want to change the app language, so that I can use the app in my preferred language.

#### Acceptance Criteria

1. WHEN the profile settings page loads THEN the system SHALL display a "Language" row with a globe icon
2. WHEN the language row is displayed THEN the system SHALL show the current language selection (e.g., "English")
3. WHEN the language row is displayed THEN the system SHALL include a navigation arrow indicating it's tappable
4. WHEN the user taps the language row THEN the system SHALL navigate to a language picker screen
5. WHEN the user selects a new language THEN the system SHALL update the app language and return to the settings page

### Requirement 5

**User Story:** As a user, I want to rate the app, so that I can share my feedback on the App Store.

#### Acceptance Criteria

1. WHEN the profile settings page loads THEN the system SHALL display a "Rate the App" row with a star icon
2. WHEN the rate app row is displayed THEN the system SHALL show "Share your feedback on the App Store." as the subtitle
3. WHEN the rate app row is displayed THEN the system SHALL include a navigation arrow
4. WHEN the user taps the rate app row THEN the system SHALL open the App Store rating interface for the VocaPin app

### Requirement 6

**User Story:** As a user, I want to send feedback, so that I can share suggestions or report issues to the developers.

#### Acceptance Criteria

1. WHEN the profile settings page loads THEN the system SHALL display a "Feedback" row with a chat bubble icon
2. WHEN the feedback row is displayed THEN the system SHALL show "Send feedback or suggestions." as the subtitle
3. WHEN the feedback row is displayed THEN the system SHALL include a navigation arrow
4. WHEN the user taps the feedback row THEN the system SHALL open the device's mail app with a pre-filled email to the support team

### Requirement 7

**User Story:** As a user, I want to access support resources, so that I can get help when I encounter issues or have questions.

#### Acceptance Criteria

1. WHEN the profile settings page loads THEN the system SHALL display a "Support" row with a question mark icon
2. WHEN the support row is displayed THEN the system SHALL show "Help Center & Contact Support." as the subtitle
3. WHEN the support row is displayed THEN the system SHALL include a navigation arrow
4. WHEN the user taps the support row THEN the system SHALL navigate to a support page or open external support resources

### Requirement 8

**User Story:** As a user, I want to see app version information and legal links, so that I can access privacy policy and terms of service.

#### Acceptance Criteria

1. WHEN the profile settings page loads THEN the system SHALL display "Vocal Sticky v1.0.0" at the bottom in small gray text
2. WHEN the footer is displayed THEN the system SHALL show "Privacy Policy" and "Terms of Service" as tappable links
3. WHEN the footer links are displayed THEN the system SHALL separate them with a center dot (·)
4. WHEN the user taps "Privacy Policy" THEN the system SHALL open the privacy policy in a web view or external browser
5. WHEN the user taps "Terms of Service" THEN the system SHALL open the terms of service in a web view or external browser

### Requirement 9

**User Story:** As a user, I want the settings page to match the app's visual design, so that I have a consistent user experience.

#### Acceptance Criteria

1. WHEN the profile settings page is displayed THEN the system SHALL use the same background color as the main app (warm beige)
2. WHEN setting rows are displayed THEN the system SHALL use white rounded rectangles with subtle shadows
3. WHEN icons are displayed THEN the system SHALL use system icons with consistent sizing and gray coloring
4. WHEN text is displayed THEN the system SHALL use the same font family and sizing as the rest of the app
5. WHEN the user navigates back THEN the system SHALL return to the main notes view with smooth animation

### Requirement 10

**User Story:** As a user, I want to navigate back from the settings page, so that I can return to my notes.

#### Acceptance Criteria

1. WHEN the profile settings page is displayed THEN the system SHALL provide a back navigation option (back button or swipe gesture)
2. WHEN the user taps the back button THEN the system SHALL return to the main notes view
3. WHEN the user swipes back THEN the system SHALL return to the main notes view
4. WHEN navigating back THEN the system SHALL preserve the current note state and position