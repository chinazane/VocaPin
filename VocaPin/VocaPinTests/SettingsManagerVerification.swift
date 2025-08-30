//
//  SettingsManagerVerification.swift
//  VocaPinTests
//
//  Created by Kiro on 8/27/25.
//

import Foundation
@testable import VocaPin

/// Manual verification of SettingsManager functionality
/// This can be run as a simple function to verify the implementation works
func verifySettingsManagerImplementation() {
    print("🧪 Starting SettingsManager verification...")
    
    // Test 1: Singleton pattern
    let instance1 = SettingsManager.shared
    let instance2 = SettingsManager.shared
    assert(instance1 === instance2, "❌ Singleton pattern failed")
    print("✅ Singleton pattern works")
    
    // Test 2: Default values
    let manager = SettingsManager.shared
    assert(!manager.isWidgetEnabled, "❌ Default widget state should be false")
    assert(manager.selectedLanguage == "English", "❌ Default language should be English")
    assert(!manager.appVersion.isEmpty, "❌ App version should not be empty")
    print("✅ Default values are correct")
    
    // Test 3: Widget settings persistence
    manager.isWidgetEnabled = true
    assert(manager.loadWidgetEnabled() == true, "❌ Widget enabled state not persisted")
    manager.isWidgetEnabled = false
    assert(manager.loadWidgetEnabled() == false, "❌ Widget disabled state not persisted")
    print("✅ Widget settings persistence works")
    
    // Test 4: Language settings persistence
    manager.selectedLanguage = "Spanish"
    assert(manager.loadSelectedLanguage() == "Spanish", "❌ Language selection not persisted")
    print("✅ Language settings persistence works")
    
    // Test 5: Language validation
    assert(manager.isLanguageSupported("English"), "❌ English should be supported")
    assert(manager.isLanguageSupported("Spanish"), "❌ Spanish should be supported")
    assert(!manager.isLanguageSupported("Klingon"), "❌ Unsupported language should return false")
    print("✅ Language validation works")
    
    // Test 6: Supported languages list
    let supportedLanguages = manager.supportedLanguages
    assert(supportedLanguages.contains("English"), "❌ Should support English")
    assert(supportedLanguages.contains("Spanish"), "❌ Should support Spanish")
    assert(supportedLanguages.contains("French"), "❌ Should support French")
    assert(supportedLanguages.count == 6, "❌ Should have 6 supported languages")
    print("✅ Supported languages list is correct")
    
    // Test 7: Version formatting
    let formattedVersion = manager.getFormattedVersion()
    assert(formattedVersion.contains("Vocal Sticky v"), "❌ Formatted version should contain app name")
    print("✅ Version formatting works")
    
    // Test 8: Widget setup guidance
    let guidance = manager.getWidgetSetupGuidance()
    assert(!guidance.isEmpty, "❌ Widget setup guidance should not be empty")
    assert(guidance.contains("VocaPin"), "❌ Guidance should mention app name")
    print("✅ Widget setup guidance works")
    
    // Test 9: Language update
    let initialLanguage = manager.selectedLanguage
    manager.updateLanguage("German")
    assert(manager.selectedLanguage == "German", "❌ Language should be updated to German")
    
    // Test invalid language update
    manager.updateLanguage("InvalidLanguage")
    assert(manager.selectedLanguage == "German", "❌ Invalid language should not change current selection")
    print("✅ Language update works")
    
    // Test 10: Settings reset
    manager.isWidgetEnabled = true
    manager.selectedLanguage = "French"
    manager.resetToDefaults()
    assert(!manager.isWidgetEnabled, "❌ Widget should be disabled after reset")
    assert(manager.selectedLanguage == "English", "❌ Language should be English after reset")
    print("✅ Settings reset works")
    
    // Test 11: Widget configuration (should not crash)
    manager.isWidgetEnabled = true
    manager.configureWidget() // Should not crash
    manager.isWidgetEnabled = false
    manager.configureWidget() // Should not crash
    print("✅ Widget configuration doesn't crash")
    
    // Test 12: Fresh install detection
    let isFresh = manager.isFreshInstall()
    manager.markAsLaunched()
    let isNotFresh = manager.isFreshInstall()
    assert(isFresh != isNotFresh, "❌ Fresh install detection should change after marking as launched")
    print("✅ Fresh install detection works")
    
    print("🎉 All SettingsManager verification tests passed!")
}