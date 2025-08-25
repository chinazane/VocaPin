//
    //  WidgetDataManager.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/23/25.
//

import Foundation
import SwiftUI
import WidgetKit

class WidgetDataManager {
    static let shared = WidgetDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.vocappin.notes")
    
    private init() {
        if userDefaults == nil {
            print("❌ Widget: Failed to create App Group UserDefaults - check App Group configuration")
        } else {
            print("✅ Widget: App Group UserDefaults initialized successfully")
            // Test basic functionality
            testAppGroup()
        }
    }
    
    private func testAppGroup() {
        guard let userDefaults = userDefaults else {
             return
        }
        
        // Test basic read/write
        let testKey = "test_key"
        let testValue = "test_value_\(Date().timeIntervalSince1970)"
        
        userDefaults.set(testValue, forKey: testKey)
        userDefaults.synchronize()
        
        /*if let readValue = userDefaults.string(forKey: testKey), readValue == testValue {
            print("✅ Widget: App Group read/write test successful")
        } else {
            print("❌ Widget: App Group read/write test failed")
        }*/
    }
    
    func saveCurrentNote(_ note: Note) {
        // Use simple dictionary format to avoid struct compatibility issues
        let uiColor = UIColor(note.color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let noteData: [String: Any] = [
            "text": note.text,
            "colorRed": Double(red),
            "colorGreen": Double(green),
            "colorBlue": Double(blue),
            "rotation": note.rotation,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Try App Group UserDefaults first
        if let appGroupDefaults = userDefaults {
            appGroupDefaults.set(noteData, forKey: "currentNote")
            appGroupDefaults.synchronize()
            
            // Verify save
            if let testData = appGroupDefaults.dictionary(forKey: "currentNote"),
               let testText = testData["text"] as? String {
                //print("✅ Widget: Verified App Group save: '\(testText)'")
            }
        } else {
            // Fallback to standard UserDefaults
            UserDefaults.standard.set(noteData, forKey: "widget_currentNote")
            UserDefaults.standard.synchronize()
         }
        
        // Reload all widgets immediately
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func saveNotes(_ notes: [Note], currentIndex: Int) {
        
        // Save the current note for the widget
        if currentIndex < notes.count {
            let currentNote = notes[currentIndex]
           // print("📝 Widget: Current note text: '\(currentNote.text)'")
            saveCurrentNote(currentNote)
        } else {
            print("⚠️ Widget: Invalid current index \(currentIndex) for \(notes.count) notes")
        }
        
        // Save current index for reference
        userDefaults?.set(currentIndex, forKey: "currentNoteIndex")
        userDefaults?.synchronize()
        
        // Force widget reload
        WidgetCenter.shared.reloadAllTimelines()
    }
}

