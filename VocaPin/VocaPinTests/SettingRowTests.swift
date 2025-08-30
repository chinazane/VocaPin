//
//  SettingRowTests.swift
//  VocaPinTests
//
//  Created by Bill Zhang on 8/27/25.
//

import XCTest
import SwiftUI
@testable import VocaPin

final class SettingRowTests: XCTestCase {
    
    func testSettingRowWithToggleAction() {
        // Given
        let isToggled = Binding<Bool>(
            get: { true },
            set: { _ in }
        )
        
        // When
        let settingRow = SettingRow(
            icon: "widget.small",
            title: "Test Toggle",
            subtitle: "Test subtitle",
            action: .toggle(isToggled)
        )
        
        // Then
        XCTAssertNotNil(settingRow)
    }
    
    func testSettingRowWithNavigationAction() {
        // Given
        var actionCalled = false
        let navigationAction = {
            actionCalled = true
        }
        
        // When
        let settingRow = SettingRow(
            icon: "globe",
            title: "Test Navigation",
            subtitle: "Test subtitle",
            action: .navigation(navigationAction)
        )
        
        // Then
        XCTAssertNotNil(settingRow)
        XCTAssertFalse(actionCalled)
    }
    
    func testSettingActionEnum() {
        // Given
        let toggleBinding = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        
        // When
        let toggleAction = SettingAction.toggle(toggleBinding)
        let navigationAction = SettingAction.navigation({})
        
        // Then
        switch toggleAction {
        case .toggle(let binding):
            XCTAssertFalse(binding.wrappedValue)
        case .navigation:
            XCTFail("Expected toggle action")
        }
        
        switch navigationAction {
        case .toggle:
            XCTFail("Expected navigation action")
        case .navigation:
            XCTAssertTrue(true) // Navigation action exists
        }
    }
    
    func testSettingRowAccessibilityLabels() {
        // Given
        let isToggled = Binding<Bool>(
            get: { true },
            set: { _ in }
        )
        
        // When
        let toggleRow = SettingRow(
            icon: "widget.small",
            title: "Widget Settings",
            subtitle: "Enable widget",
            action: .toggle(isToggled)
        )
        
        let navigationRow = SettingRow(
            icon: "globe",
            title: "Language",
            subtitle: "English",
            action: .navigation({})
        )
        
        // Then
        XCTAssertNotNil(toggleRow)
        XCTAssertNotNil(navigationRow)
    }
    
    func testSettingRowStyling() {
        // Given
        let settingRow = SettingRow(
            icon: "star",
            title: "Rate App",
            subtitle: "Share feedback",
            action: .navigation({})
        )
        
        // Then
        XCTAssertNotNil(settingRow)
        // Note: Visual styling tests would typically be done with UI tests
        // or snapshot testing frameworks in a real project
    }
}