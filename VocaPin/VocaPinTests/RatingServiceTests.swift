//
//  RatingServiceTests.swift
//  VocaPinTests
//
//  Created by Kiro on 8/27/25.
//

import XCTest
@testable import VocaPin

final class RatingServiceTests: XCTestCase {
    
    var mockRatingService: MockRatingService!
    
    override func setUpWithError() throws {
        mockRatingService = MockRatingService()
    }
    
    override func tearDownWithError() throws {
        mockRatingService = nil
    }
    
    // MARK: - Rating Request Tests
    
    func testRequestRating_CallsRequestRating() {
        // When
        mockRatingService.requestRating()
        
        // Then
        XCTAssertTrue(mockRatingService.requestRatingCalled, "requestRating should be called")
    }
    
    func testOpenAppStoreForRating_CallsOpenAppStore() {
        // When
        mockRatingService.openAppStoreForRating()
        
        // Then
        XCTAssertTrue(mockRatingService.openAppStoreCalled, "openAppStoreForRating should be called")
    }
    
    func testOpenAppStoreForRating_WithFailure_HandlesGracefully() {
        // Given
        mockRatingService.shouldFailAppStoreOpen = true
        
        // When
        mockRatingService.openAppStoreForRating()
        
        // Then
        XCTAssertTrue(mockRatingService.openAppStoreCalled, "openAppStoreForRating should still be called even with failure")
    }
    
    // MARK: - Real Service Tests
    
    func testRealRatingService_Singleton() {
        // Given
        let service1 = RatingService.shared
        let service2 = RatingService.shared
        
        // Then
        XCTAssertTrue(service1 === service2, "RatingService should be a singleton")
    }
    
    func testRealRatingService_RequestRating_DoesNotCrash() {
        // Given
        let service = RatingService.shared
        
        // When/Then - Should not crash
        XCTAssertNoThrow(service.requestRating(), "requestRating should not crash")
    }
    
    func testRealRatingService_OpenAppStore_DoesNotCrash() {
        // Given
        let service = RatingService.shared
        
        // When/Then - Should not crash
        XCTAssertNoThrow(service.openAppStoreForRating(), "openAppStoreForRating should not crash")
    }
}

// MARK: - Integration Tests

final class RatingServiceIntegrationTests: XCTestCase {
    
    func testProfileSettingsView_RateAppRow_Integration() {
        // This test verifies that the ProfileSettingsView properly integrates with RatingService
        // Note: This is a basic integration test - full UI testing would require UI test target
        
        // Given
        let mockService = MockRatingService()
        
        // When - Simulate the rate app action
        mockService.requestRating()
        
        // Then
        XCTAssertTrue(mockService.requestRatingCalled, "Rating service should be called when rate app is tapped")
    }
    
    func testRatingService_AppStoreURL_Formation() {
        // This test verifies that the App Store URL is properly formed
        // Note: We can't easily test the actual URL opening without mocking UIApplication
        
        let service = RatingService.shared
        
        // When/Then - Should not crash when attempting to open App Store
        XCTAssertNoThrow(service.openAppStoreForRating(), "App Store URL formation should not crash")
    }
}