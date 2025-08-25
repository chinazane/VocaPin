# VocaPin Widget Setup Guide

## Overview
The VocaPin widget allows users to view their sticky notes directly on their iPhone home screen and lock screen. The widget displays the currently selected note from the main app and updates automatically when notes are changed.

## Widget Features

### Widget Sizes
- **Small Widget**: Shows a compact sticky note with the current note text
- **Medium Widget**: Shows the sticky note plus app branding and instructions
- **Large Widget**: Shows a large sticky note with header information

### Key Features
- 🎨 **Color Preservation**: Widget maintains the same color as the note in the app
- 📝 **Real-time Updates**: Widget updates when you change notes or edit text
- 📌 **Visual Consistency**: Same cork board background and red pin design
- 🔄 **Auto Refresh**: Widget refreshes every hour or when app data changes

## Setup Instructions

### 1. Add Widget Extension to Xcode Project
1. In Xcode, go to **File > New > Target**
2. Select **Widget Extension**
3. Name it "VocaPinWidget"
4. Make sure "Include Configuration Intent" is **unchecked**
5. Click **Finish**

### 2. Configure App Groups
1. Select your main app target in Xcode
2. Go to **Signing & Capabilities**
3. Add **App Groups** capability
4. Create a new group: `group.vocapin.notes`
5. Repeat for the widget extension target

### 3. Update Bundle Identifiers
- Main app: `com.yourcompany.vocapin`
- Widget: `com.yourcompany.vocapin.widget`

### 4. Add Files to Targets
Make sure these files are added to both targets:
- `WidgetDataManager.swift`
- `WidgetNote.swift` (widget target only)

## How to Add Widget to Home Screen

### iOS 14+ Instructions
1. Long press on your home screen
2. Tap the **+** button in the top-left corner
3. Search for "VocaPin" or scroll to find it
4. Select your preferred widget size:
   - **Small**: Compact note display
   - **Medium**: Note + app info
   - **Large**: Large note display
5. Tap **Add Widget**
6. Position the widget where you want it
7. Tap **Done**

### iOS 16+ Lock Screen Widget
1. Long press on your lock screen
2. Tap **Customize**
3. Tap the area below the time
4. Tap **+** to add widgets
5. Find and select VocaPin
6. Choose the small widget size
7. Tap **Done**

## Widget Behavior

### Data Synchronization
- Widget shows the **currently selected note** from the main app
- Updates automatically when you:
  - Switch between notes (swipe left/right)
  - Edit note text
  - Change note colors
  - Open the app

### Update Frequency
- **Immediate**: When app data changes
- **Scheduled**: Every hour for background updates
- **Manual**: Pull down on home screen to refresh

### Interaction
- **Tap widget**: Opens the main VocaPin app
- **No direct editing**: Use the main app to edit notes

## Troubleshooting

### Widget Not Updating
1. Force close and reopen the main app
2. Edit a note to trigger an update
3. Remove and re-add the widget

### Widget Shows Sample Data
1. Open the main VocaPin app
2. Navigate through your notes
3. The widget should update within a few seconds

### Widget Not Appearing
1. Check that both app and widget have the same App Group
2. Verify bundle identifiers are correct
3. Clean and rebuild the project

## Technical Details

### Data Storage
- Uses **App Groups** for data sharing between app and widget
- Stores current note in `UserDefaults` with suite name
- JSON encoding for data persistence

### Performance
- Lightweight widget implementation
- Minimal memory usage
- Efficient timeline updates

### Privacy
- All data stays on device
- No network requests from widget
- Uses same security as main app

## Customization Options

### Future Enhancements
- Multiple note widgets
- Widget configuration for note selection
- Interactive widget buttons (iOS 17+)
- Live Activities for note editing

### Current Limitations
- Shows only current/selected note
- No direct editing from widget
- Updates require app interaction

## Support
If you encounter issues with the widget:
1. Check the troubleshooting section above
2. Ensure proper Xcode project configuration
3. Verify App Groups are correctly set up
4. Test on physical device (widgets don't work in simulator for all features)