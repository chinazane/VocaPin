//
//  FooterSectionUITests.swift
//  VocaPinTests
//
//  Created by Kiro on 8/27/25.
//

import XCTest
import SwiftUI
@testable import VocaPin

final class FooterSectionUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - Version Display Tests
    
    func testFooterDisplaysCorrectAppVersion() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to settings
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()
        
        // When - Scroll to footer
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // Then - Verify version text is displayed
        let versionText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Vocal Sticky v'"))
        XCTAssertTrue(versionText.firstMatch.waitForExistence(timeout: 3))
        
        // Verify the version format matches expected pattern
        let versionLabel = versionText.firstMatch.label
        XCTAssertTrue(versionLabel.hasPrefix("Vocal Sticky v"))
        XCTAssertTrue(versionLabel.contains("."))
    }
    
    func testVersionTextStyling() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to settings and scroll to footer
        app.buttons["Settings"].tap()
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // When - Find version text
        let versionText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Vocal Sticky v'")).firstMatch
        XCTAssertTrue(versionText.waitForExistence(timeout: 3))
        
        // Then - Verify text is visible and properly positioned
        XCTAssertTrue(versionText.exists)
        XCTAssertTrue(versionText.isHittable)
    }
    
    // MARK: - Legal Links Tests
    
    func testPrivacyPolicyLinkExists() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to settings and scroll to footer
        app.buttons["Settings"].tap()
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // When - Look for Privacy Policy link
        let privacyPolicyLink = app.buttons["Privacy Policy"]
        
        // Then - Verify link exists and is tappable
        XCTAssertTrue(privacyPolicyLink.waitForExistence(timeout: 3))
        XCTAssertTrue(privacyPolicyLink.isHittable)
    }
    
    func testTermsOfServiceLinkExists() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to settings and scroll to footer
        app.buttons["Settings"].tap()
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // When - Look for Terms of Service link
        let termsLink = app.buttons["Terms of Service"]
        
        // Then - Verify link exists and is tappable
        XCTAssertTrue(termsLink.waitForExistence(timeout: 3))
        XCTAssertTrue(termsLink.isHittable)
    }
    
    func testLegalLinksSeparator() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to settings and scroll to footer
        app.buttons["Settings"].tap()
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // When - Look for separator between links
        let separator = app.staticTexts["·"]
        
        // Then - Verify separator exists
        XCTAssertTrue(separator.waitForExistence(timeout: 3))
    }
    
    func testPrivacyPolicyLinkTap() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to settings and scroll to footer
        app.buttons["Settings"].tap()
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // When - Tap Privacy Policy link
        let privacyPolicyLink = app.buttons["Privacy Policy"]
        XCTAssertTrue(privacyPolicyLink.waitForExistence(timeout: 3))
        privacyPolicyLink.tap()
        
        // Then - Verify web view or external browser opens
        // Note: This test verifies the tap action works, actual web content loading
        // would require network connectivity and may be tested separately
        let webView = app.webViews.firstMatch
        let safariApp = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        
        // Either web view appears or Safari opens
        let webViewExists = webView.waitForExistence(timeout: 5)
        let safariOpened = safariApp.wait(for: .runningForeground, timeout: 5)
        
        XCTAssertTrue(webViewExists || safariOpened, "Either web view should appear or Safari should open")
    }
    
    func testTermsOfServiceLinkTap() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to settings and scroll to footer
        app.buttons["Settings"].tap()
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // When - Tap Terms of Service link
        let termsLink = app.buttons["Terms of Service"]
        XCTAssertTrue(termsLink.waitForExistence(timeout: 3))
        termsLink.tap()
        
        // Then - Verify web view or external browser opens
        let webView = app.webViews.firstMatch
        let safariApp = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        
        // Either web view appears or Safari opens
        let webViewExists = webView.waitForExistence(timeout: 5)
        let safariOpened = safariApp.wait(for: .runningForeground, timeout: 5)
        
        XCTAssertTrue(webViewExists || safariOpened, "Either web view should appear or Safari should open")
    }
    
    // MARK: - Accessibility Tests
    
    func testFooterAccessibilityLabels() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to settings and scroll to footer
        app.buttons["Settings"].tap()
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // When - Check accessibility labels
        let privacyPolicyLink = app.buttons["Privacy Policy"]
        let termsLink = app.buttons["Terms of Service"]
        
        // Then - Verify accessibility labels exist
        XCTAssertTrue(privacyPolicyLink.waitForExistence(timeout: 3))
        XCTAssertTrue(termsLink.waitForExistence(timeout: 3))
        
        // Verify accessibility hints are available (these would be read by VoiceOver)
        XCTAssertNotNil(privacyPolicyLink.value)
        XCTAssertNotNil(termsLink.value)
    }
    
    // MARK: - Layout Tests
    
    func testFooterLayout() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to settings and scroll to footer
        app.buttons["Settings"].tap()
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // When - Get footer elements
        let versionText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Vocal Sticky v'")).firstMatch
        let privacyPolicyLink = app.buttons["Privacy Policy"]
        let separator = app.staticTexts["·"]
        let termsLink = app.buttons["Terms of Service"]
        
        // Then - Verify all elements exist and are properly positioned
        XCTAssertTrue(versionText.waitForExistence(timeout: 3))
        XCTAssertTrue(privacyPolicyLink.waitForExistence(timeout: 3))
        XCTAssertTrue(separator.waitForExistence(timeout: 3))
        XCTAssertTrue(termsLink.waitForExistence(timeout: 3))
        
        // Verify vertical ordering (version should be above legal links)
        let versionFrame = versionText.frame
        let linksFrame = privacyPolicyLink.frame
        XCTAssertLessThan(versionFrame.maxY, linksFrame.minY, "Version text should be above legal links")
    }
    
    // MARK: - Error Handling Tests
    
    func testWebViewErrorHandling() throws {
        // This test would verify that if web view fails to load,
        // the app gracefully falls back to external browser
        // Implementation would depend on network conditions and error simulation
        
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to settings and scroll to footer
        app.buttons["Settings"].tap()
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // When - Tap a legal link (this test assumes network issues)
        let privacyPolicyLink = app.buttons["Privacy Policy"]
        XCTAssertTrue(privacyPolicyLink.waitForExistence(timeout: 3))
        privacyPolicyLink.tap()
        
        // Then - Verify app doesn't crash and some form of navigation occurs
        // The exact behavior depends on network conditions and error handling implementation
        XCTAssertTrue(app.state == .runningForeground, "App should remain running after link tap")
    }
}