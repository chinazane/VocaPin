//
//  SettingsManager.swift
//  VocaPin
//
//  Created by Kiro on 8/27/25.
//

import Foundation
import SwiftUI
import WidgetKit

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    // MARK: - Published Properties
    @Published var isWidgetEnabled: Bool {
        didSet {
            saveWidgetEnabled(isWidgetEnabled)
        }
    }
    
    @Published var selectedLanguage: String {
        didSet {
            saveSelectedLanguage(selectedLanguage)
        }
    }
    
    @Published var appVersion: String
    
    // MARK: - UserDefaults Keys
    private let widgetEnabledKey = "WidgetEnabled"
    private let selectedLanguageKey = "SelectedLanguage"
    
    // MARK: - Supported Languages
    let supportedLanguages = [
        "English",
        "Spanish", 
        "French",
        "German",
        "Japanese",
        "Chinese (Simplified)"
    ]
    
    // MARK: - Initialization
    private init() {
        // Load persisted values or set defaults
        self.isWidgetEnabled = UserDefaults.standard.bool(forKey: widgetEnabledKey)
        self.selectedLanguage = UserDefaults.standard.string(forKey: selectedLanguageKey) ?? "English"
        
        // Get app version from bundle
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersion = version
        } else {
            self.appVersion = "1.0.0" // Default fallback
        }
    }
    
    // MARK: - Widget Management
    
    /// Saves the widget enabled state to UserDefaults
    private func saveWidgetEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: widgetEnabledKey)
    }
    
    /// Loads the widget enabled state from UserDefaults
    func loadWidgetEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: widgetEnabledKey)
    }
    
    /// Configures widget based on enabled state
    func configureWidget() {
        if isWidgetEnabled {
            // Reload widget timelines when enabled
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            // Clear widget data when disabled
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    /// Provides guidance for adding widget to home screen
    func getWidgetSetupGuidance() -> String {
        return """
        To add the VocaPin widget to your home screen:
        1. Long press on your home screen
        2. Tap the '+' button in the top corner
        3. Search for 'VocaPin'
        4. Select your preferred widget size
        5. Tap 'Add Widget'
        """
    }
    
    // MARK: - Language Management
    
    /// Gets the current system language display name
    func getCurrentSystemLanguage() -> String {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        let locale = Locale(identifier: preferredLanguage)
        
        // Get the display name of the language in the current locale
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        if let languageName = locale.localizedString(forLanguageCode: languageCode) {
            return languageName.capitalized
        }
        
        return "English" // Fallback
    }
    
    /// Opens iOS Settings app to the app-specific language settings
    func openLanguageSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            print("Failed to create settings URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                if success {
                    print("Successfully opened iOS Settings")
                } else {
                    print("Failed to open iOS Settings")
                }
            }
        } else {
            print("Cannot open iOS Settings URL")
        }
    }
    
    /// Saves the selected language to UserDefaults
    private func saveSelectedLanguage(_ language: String) {
        UserDefaults.standard.set(language, forKey: selectedLanguageKey)
    }
    
    /// Loads the selected language from UserDefaults
    func loadSelectedLanguage() -> String {
        return UserDefaults.standard.string(forKey: selectedLanguageKey) ?? "English"
    }
    
    /// Validates if a language is supported
    func isLanguageSupported(_ language: String) -> Bool {
        return supportedLanguages.contains(language)
    }
    
    /// Updates the app language and applies localization
    func updateLanguage(_ newLanguage: String) {
        guard isLanguageSupported(newLanguage) else {
            print("Unsupported language: \(newLanguage)")
            return
        }
        
        selectedLanguage = newLanguage
        
        // Apply language change to the app
        // Note: Full localization implementation would require additional setup
        // This provides the foundation for language management
        applyLanguageChange(newLanguage)
    }
    
    /// Applies the language change to the app
    private func applyLanguageChange(_ language: String) {
        // This method would integrate with the app's localization system
        // For now, it serves as a placeholder for future localization implementation
        print("Language changed to: \(language)")
        
        // Notify other parts of the app about language change
        NotificationCenter.default.post(
            name: NSNotification.Name("LanguageChanged"),
            object: nil,
            userInfo: ["newLanguage": language]
        )
    }
    
    // MARK: - Version Management
    
    /// Gets the formatted app version string for display
    func getFormattedVersion() -> String {
        return "Vocal Sticky v\(appVersion)"
    }
    
    /// Checks if this is a fresh install (no previous settings)
    func isFreshInstall() -> Bool {
        return !UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
    }
    
    /// Marks the app as having been launched before
    func markAsLaunched() {
        UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
    }
    
    // MARK: - Settings Reset
    
    /// Resets all settings to default values
    func resetToDefaults() {
        isWidgetEnabled = false
        selectedLanguage = "English"
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: widgetEnabledKey)
        UserDefaults.standard.removeObject(forKey: selectedLanguageKey)
        
        print("Settings reset to defaults")
    }
    
    // MARK: - Data Validation
    
    /// Validates and repairs corrupted settings data
    func validateAndRepairSettings() {
        // Validate language setting
        if !isLanguageSupported(selectedLanguage) {
            print("Invalid language detected: \(selectedLanguage), resetting to English")
            selectedLanguage = "English"
        }
        
        // Validate widget setting (Bool is always valid, no repair needed)
        
        print("Settings validation completed")
    }
}