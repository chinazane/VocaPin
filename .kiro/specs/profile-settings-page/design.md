# Profile Settings Page Design Document

## Overview

The Profile Settings Page is a comprehensive settings interface that provides users with access to app configuration, premium features, support resources, and legal information. The design maintains visual consistency with the existing VocaPin app while introducing new UI patterns for settings management.

The page follows iOS design conventions with a scrollable list of settings grouped into logical sections, each with clear visual hierarchy and intuitive navigation patterns.

## Architecture

### View Hierarchy

```
ProfileSettingsView (Main Container)
├── NavigationView
│   ├── ScrollView
│   │   ├── VStack (Main Content)
│   │   │   ├── HeaderSection
│   │   │   │   ├── App Logo
│   │   │   │   ├── App Title
│   │   │   │   └── Tagline
│   │   │   ├── PremiumSection
│   │   │   │   └── UpgradeCard
│   │   │   ├── SettingsSection
│   │   │   │   ├── WidgetSettingRow
│   │   │   │   ├── LanguageSettingRow
│   │   │   │   ├── RateAppRow
│   │   │   │   ├── FeedbackRow
│   │   │   │   └── SupportRow
│   │   │   └── FooterSection
│   │   │       ├── Version Info
│   │   │       └── Legal Links
```

### State Management

The ProfileSettingsView will use `@StateObject` for settings management and `@State` for local UI state:

```swift
@StateObject private var settingsManager = SettingsManager.shared
@State private var showLanguagePicker = false
@State private var isWidgetEnabled = false
@Environment(\.dismiss) private var dismiss
```

### Navigation Integration

The settings page integrates with the existing app navigation by:
- Replacing the current settings gear button action in HeaderView
- Using SwiftUI's NavigationView for proper back navigation
- Maintaining the existing app's navigation patterns

## Components and Interfaces

### 1. SettingsManager

A new singleton class to manage app-wide settings:

```swift
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var isWidgetEnabled: Bool
    @Published var selectedLanguage: String
    @Published var appVersion: String
    
    private let widgetEnabledKey = "WidgetEnabled"
    private let selectedLanguageKey = "SelectedLanguage"
    
    // Methods for persistence and widget management
}
```

### 2. ProfileSettingsView

Main settings view with the following key components:

#### Header Section
- **App Logo**: Uses existing app icon (60x60 points)
- **Title**: "Vocal Sticky" in title font weight
- **Tagline**: "Speak it. Stick it." in secondary gray

#### Premium Section
- **Background**: Yellow to orange gradient matching app theme
- **Icon**: Lock symbol in white
- **Content**: "Unlock Premium" title with feature description
- **Action**: "Upgrade" button with rounded corners

#### Settings Rows
Each row follows a consistent pattern:
- **Container**: White rounded rectangle (cornerRadius: 12)
- **Icon**: System icon in gray (24x24 points)
- **Content**: Title and subtitle in VStack
- **Action**: Toggle switch or navigation arrow
- **Spacing**: 16 points between rows

### 3. SettingRow Component

Reusable component for consistent row styling:

```swift
struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: SettingAction
    
    enum SettingAction {
        case toggle(Binding<Bool>)
        case navigation(() -> Void)
    }
}
```

### 4. Language Picker

Modal sheet for language selection:
- List of supported languages
- Current selection indicator
- Dismiss on selection

## Data Models

### Settings Data Structure

```swift
struct AppSettings {
    var isWidgetEnabled: Bool = false
    var selectedLanguage: String = "English"
    var hasRatedApp: Bool = false
}
```

### Language Support

Initial language options:
- English (default)
- Spanish
- French
- German
- Japanese
- Chinese (Simplified)

## Error Handling

### Widget Configuration Errors
- Handle iOS widget permission issues
- Provide user guidance for manual widget setup
- Graceful fallback if widget APIs fail

### External Navigation Errors
- App Store rating: Fallback to web URL if native fails
- Email feedback: Handle no mail app configured
- Support links: Validate URLs before opening

### Data Persistence Errors
- UserDefaults write failures
- Invalid language selection recovery
- Settings corruption recovery

## Testing Strategy

### Unit Tests
1. **SettingsManager Tests**
   - Settings persistence and retrieval
   - Default value handling
   - Data validation

2. **Component Tests**
   - SettingRow rendering with different actions
   - Toggle state management
   - Navigation action handling

### UI Tests
1. **Navigation Flow Tests**
   - Settings page access from main app
   - Back navigation functionality
   - Language picker modal presentation

2. **Interaction Tests**
   - Widget toggle functionality
   - External link opening (App Store, email, support)
   - Premium upgrade button action

3. **Visual Tests**
   - Consistent styling with app theme
   - Proper icon and text alignment
   - Responsive layout on different screen sizes

### Integration Tests
1. **Widget Integration**
   - Widget enable/disable functionality
   - Home screen widget behavior
   - Data sync between app and widget

2. **System Integration**
   - App Store rating interface
   - Mail app integration for feedback
   - Language change effects on app UI

## Visual Design Specifications

### Color Palette
- **Background**: `Color(red: 0.9, green: 0.85, blue: 0.8)` (existing app background)
- **Card Background**: `Color.white`
- **Premium Gradient**: `LinearGradient(colors: [Color.yellow, Color.orange])`
- **Text Primary**: `Color.black`
- **Text Secondary**: `Color.gray`
- **Icons**: `Color.gray`

### Typography
- **Title**: `.title2` with `.medium` weight
- **Setting Title**: `.body` with `.medium` weight  
- **Setting Subtitle**: `.caption` with `.regular` weight
- **Footer**: `.caption2` with `.regular` weight

### Spacing and Layout
- **Section Spacing**: 24 points between major sections
- **Row Spacing**: 16 points between setting rows
- **Internal Padding**: 16 points inside cards
- **Horizontal Margins**: 20 points from screen edges
- **Corner Radius**: 12 points for cards and buttons

### Shadows and Effects
- **Card Shadow**: `color: .black.opacity(0.1), radius: 2, x: 0, y: 1`
- **Button Shadow**: `color: .black.opacity(0.2), radius: 3, x: 0, y: 2`

## Accessibility

### VoiceOver Support
- Proper accessibility labels for all interactive elements
- Grouped related content (icon + text + action)
- Clear navigation announcements

### Dynamic Type Support
- All text scales with system font size preferences
- Maintains layout integrity at larger sizes
- Icon sizes remain consistent

### Color Accessibility
- Sufficient contrast ratios for all text
- Icons remain visible in high contrast mode
- Toggle states clearly distinguishable

## Performance Considerations

### Lazy Loading
- Settings values loaded on demand
- Language list populated when picker opens
- External resources (App Store, support) loaded asynchronously

### Memory Management
- Proper cleanup of observers and bindings
- Efficient image loading for icons
- Minimal state retention when view disappears

### Animation Performance
- Smooth transitions between views
- Optimized toggle animations
- Efficient scroll performance with multiple rows

## Platform Integration

### iOS Widget System
- WidgetKit integration for home screen widgets
- Proper widget timeline management
- User guidance for widget setup

### App Store Integration
- StoreKit for in-app rating prompts
- Fallback to App Store URL for reviews
- Proper handling of rating completion

### System Services
- MessageUI for feedback emails
- Safari for external links
- Localization system for language changes

## Future Extensibility

### Additional Settings
- Notification preferences
- Data export/import options
- Theme customization
- Advanced speech recognition settings

### Premium Features Integration
- Feature flag system for premium content
- Subscription status management
- Premium feature discovery

### Analytics Integration
- Settings usage tracking
- Feature adoption metrics
- User preference insights