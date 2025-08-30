//
//  RatingService.swift
//  VocaPin
//
//  Created by Kiro on 8/27/25.
//

import Foundation
import StoreKit
import UIKit

protocol RatingServiceProtocol {
    func requestRating()
    func openAppStoreForRating()
}

class RatingService: RatingServiceProtocol {
    static let shared = RatingService()
    
    // App Store ID - should be configured when app is published
    private let appStoreID = "YOUR_APP_STORE_ID"
    
    private init() {}
    
    /// Requests an in-app rating using StoreKit
    func requestRating() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else {
            // Fallback if no window scene is available
            openAppStoreForRating()
            return
        }
        
        // Use StoreKit API (handles both iOS 17 and 18)
        // Note: While deprecated in iOS 18, it still works and provides compatibility
        SKStoreReviewController.requestReview(in: windowScene)
    }
    
    /// Opens the App Store directly for rating (fallback method)
    func openAppStoreForRating() {
        let appStoreURL: String
        
        if appStoreID != "YOUR_APP_STORE_ID" {
            // Use actual App Store ID if configured
            appStoreURL = "https://apps.apple.com/app/id\(appStoreID)?action=write-review"
        } else {
            // Generic App Store search as fallback
            appStoreURL = "https://apps.apple.com/search?term=VocaPin"
        }
        
        guard let url = URL(string: appStoreURL) else {
            print("RatingService: Invalid App Store URL")
            return
        }
        
        UIApplication.shared.open(url) { success in
            if !success {
                print("RatingService: Failed to open App Store URL for rating")
            }
        }
    }
}

// MARK: - Mock for Testing
class MockRatingService: RatingServiceProtocol {
    var requestRatingCalled = false
    var openAppStoreCalled = false
    var shouldFailAppStoreOpen = false
    
    func requestRating() {
        requestRatingCalled = true
    }
    
    func openAppStoreForRating() {
        openAppStoreCalled = true
        if shouldFailAppStoreOpen {
            print("MockRatingService: Simulated App Store open failure")
        }
    }
}