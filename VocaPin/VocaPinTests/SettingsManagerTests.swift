//
//  SettingsManagerTests.swift
//  VocaPinTests
//
//  Created by Kiro on 8/27/25.
//

import XCTest
import SwiftUI
import Combine
@testable import VocaPin

final class SettingsManagerTests: XCTestCase {
    
    var settingsManager: SettingsManager!
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        clearUserDefaults()
        // Get a fresh instance for testing
        settingsManager = SettingsManager.shared
    }
    
    override func tearDown() {
        // Clean up after each test
        clearUserDefaults()
        super.tearDown()
    }
    
    private func clearUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "WidgetEnabled")
        defaults.removeObject(forKey: "SelectedLanguage")
        defaults.removeObject(forKey: "HasLaunchedBefore")
    }
    
    // MARK: - Initialization Tests
    
    func testSingletonPattern() {
        // Test that SettingsManager follows singleton pattern
        let instance1 = SettingsManager.shared
        let instance2 = SettingsManager.shared
        
        XCTAssertTrue(instance1 === instance2, "SettingsManager should be a singleton")
    }
    
    func testDefaultValues() {
        // Test that default values are set correctly on first launch
        XCTAssertFalse(settingsManager.isWidgetEnabled, "Widget should be disabled by default")
        XCTAssertEqual(settingsManager.selectedLanguage, "English", "Default language should be English")
        XCTAssertFalse(settingsManager.appVersion.isEmpty, "App version should not be empty")
    }
    
    func testAppVersionRetrieval() {
        // Test that app version is retrieved correctly
        let version = settingsManager.appVersion
        XCTAssertFalse(version.isEmpty, "App version should not be empty")
        
        let formattedVersion = settingsManager.getFormattedVersion()
        XCTAssertTrue(formattedVersion.contains("Vocal Sticky v"), "Formatted version should contain app name")
        XCTAssertTrue(formattedVersion.contains(version), "Formatted version should contain version number")
    }
    
    // MARK: - Widget Management Tests
    
    func testWidgetEnabledPersistence() {
        // Test widget enabled state persistence
        settingsManager.isWidgetEnabled = true
        XCTAssertTrue(settingsManager.loadWidgetEnabled(), "Widget enabled state should be persisted")
        
        settingsManager.isWidgetEnabled = false
        XCTAssertFalse(settingsManager.loadWidgetEnabled(), "Widget disabled state should be persisted")
    }
    
    func testWidgetSetupGuidance() {
        // Test widget setup guidance text
        let guidance = settingsManager.getWidgetSetupGuidance()
        
        XCTAssertFalse(guidance.isEmpty, "Widget setup guidance should not be empty")
        XCTAssertTrue(guidance.contains("VocaPin"), "Guidance should mention app name")
        XCTAssertTrue(guidance.contains("home screen"), "Guidance should mention home screen")
        XCTAssertTrue(guidance.contains("Add Widget"), "Guidance should mention adding widget")
    }
    
    func testWidgetConfiguration() {
        // Test widget configuration method doesn't crash
        settingsManager.isWidgetEnabled = true
        XCTAssertNoThrow(settingsManager.configureWidget(), "Widget configuration should not throw")
        
        settingsManager.isWidgetEnabled = false
        XCTAssertNoThrow(settingsManager.configureWidget(), "Widget configuration should not throw when disabled")
    }
    
    // MARK: - Language Management Tests
    
    func testLanguagePersistence() {
        // Test language selection persistence
        settingsManager.selectedLanguage = "Spanish"
        XCTAssertEqual(settingsManager.loadSelectedLanguage(), "Spanish", "Selected language should be persisted")
        
        settingsManager.selectedLanguage = "French"
        XCTAssertEqual(settingsManager.loadSelectedLanguage(), "French", "Language change should be persisted")
    }
    
    func testSupportedLanguages() {
        // Test supported languages list
        let supportedLanguages = settingsManager.supportedLanguages
        
        XCTAssertFalse(supportedLanguages.isEmpty, "Supported languages should not be empty")
        XCTAssertTrue(supportedLanguages.contains("English"), "Should support English")
        XCTAssertTrue(supportedLanguages.contains("Spanish"), "Should support Spanish")
        XCTAssertTrue(supportedLanguages.contains("French"), "Should support French")
        XCTAssertTrue(supportedLanguages.contains("German"), "Should support German")
        XCTAssertTrue(supportedLanguages.contains("Japanese"), "Should support Japanese")
        XCTAssertTrue(supportedLanguages.contains("Chinese (Simplified)"), "Should support Chinese (Simplified)")
    }
    
    func testLanguageValidation() {
        // Test language validation
        XCTAssertTrue(settingsManager.isLanguageSupported("English"), "English should be supported")
        XCTAssertTrue(settingsManager.isLanguageSupported("Spanish"), "Spanish should be supported")
        XCTAssertFalse(settingsManager.isLanguageSupported("Klingon"), "Unsupported language should return false")
        XCTAssertFalse(settingsManager.isLanguageSupported(""), "Empty language should return false")
    }
    
    func testLanguageUpdate() {
        // Test language update functionality
        let initialLanguage = settingsManager.selectedLanguage
        
        settingsManager.updateLanguage("Spanish")
        XCTAssertEqual(settingsManager.selectedLanguage, "Spanish", "Language should be updated to Spanish")
        
        // Test invalid language update
        settingsManager.updateLanguage("InvalidLanguage")
        XCTAssertEqual(settingsManager.selectedLanguage, "Spanish", "Invalid language should not change current selection")
    }
    
    // MARK: - Fresh Install Tests
    
    func testFreshInstallDetection() {
        // Test fresh install detection
        XCTAssertTrue(settingsManager.isFreshInstall(), "Should detect fresh install initially")
        
        settingsManager.markAsLaunched()
        XCTAssertFalse(settingsManager.isFreshInstall(), "Should not detect fresh install after marking as launched")
    }
    
    // MARK: - Settings Reset Tests
    
    func testSettingsReset() {
        // Set some non-default values
        settingsManager.isWidgetEnabled = true
        settingsManager.selectedLanguage = "Spanish"
        
        // Reset settings
        settingsManager.resetToDefaults()
        
        // Verify reset to defaults
        XCTAssertFalse(settingsManager.isWidgetEnabled, "Widget should be disabled after reset")
        XCTAssertEqual(settingsManager.selectedLanguage, "English", "Language should be English after reset")
    }
    
    // MARK: - Data Validation Tests
    
    func testSettingsValidationAndRepair() {
        // Set invalid language directly in UserDefaults
        UserDefaults.standard.set("InvalidLanguage", forKey: "SelectedLanguage")
        
        // Create new instance to load corrupted data
        let corruptedManager = SettingsManager.shared
        
        // Validate and repair
        corruptedManager.validateAndRepairSettings()
        
        // Verify repair
        XCTAssertTrue(corruptedManager.isLanguageSupported(corruptedManager.selectedLanguage), 
                     "Invalid language should be repaired to supported language")
    }
    
    // MARK: - Published Properties Tests
    
    func testPublishedPropertiesUpdate() {
        // Test that published properties trigger updates
        let expectation = XCTestExpectation(description: "Published property should update")
        
        var cancellables = Set<AnyCancellable>()
        
        settingsManager.$isWidgetEnabled
            .dropFirst() // Skip initial value
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        settingsManager.isWidgetEnabled = true
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Integration Tests

final class SettingsManagerIntegrationTests: XCTestCase {
    
    var settingsManager: SettingsManager!
    
    override func setUp() {
        super.setUp()
        settingsManager = SettingsManager.shared
    }
    
    func testUserDefaultsIntegration() {
        // Test integration with UserDefaults
        let testLanguage = "German"
        
        settingsManager.selectedLanguage = testLanguage
        
        // Verify UserDefaults was updated
        let storedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage")
        XCTAssertEqual(storedLanguage, testLanguage, "UserDefaults should be updated when property changes")
    }
    
    func testNotificationCenterIntegration() {
        // Test language change notification
        let expectation = XCTestExpectation(description: "Language change notification should be posted")
        
        let observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("LanguageChanged"),
            object: nil,
            queue: .main
        ) { notification in
            if let newLanguage = notification.userInfo?["newLanguage"] as? String,
               newLanguage == "French" {
                expectation.fulfill()
            }
        }
        
        settingsManager.updateLanguage("French")
        
        wait(for: [expectation], timeout: 1.0)
        
        NotificationCenter.default.removeObserver(observer)
    }
}

// MARK: - Performance Tests

final class SettingsManagerPerformanceTests: XCTestCase {
    
    func testSettingsLoadPerformance() {
        // Test performance of loading settings
        let settingsManager = SettingsManager.shared
        
        measure {
            _ = settingsManager.loadWidgetEnabled()
            _ = settingsManager.loadSelectedLanguage()
            _ = settingsManager.getFormattedVersion()
        }
    }
    
    func testSettingsSavePerformance() {
        // Test performance of saving settings
        let settingsManager = SettingsManager.shared
        
        measure {
            settingsManager.isWidgetEnabled = true
            settingsManager.selectedLanguage = "Spanish"
            settingsManager.isWidgetEnabled = false
            settingsManager.selectedLanguage = "English"
        }
    }
}

// MARK: - Helper Extensions

import Combine

extension XCTestCase {
    func waitForPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output where T.Failure == Never {
        
        var result: T.Output?
        let expectation = XCTestExpectation(description: "Publisher")
        
        let cancellable = publisher.sink { value in
            result = value
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeout)
        cancellable.cancel()
        
        guard let unwrappedResult = result else {
            XCTFail("Publisher did not emit a value", file: file, line: line)
            throw XCTestError(.failureWhileWaiting)
        }
        
        return unwrappedResult
    }
}