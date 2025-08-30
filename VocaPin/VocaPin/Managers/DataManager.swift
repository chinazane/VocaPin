//
//  DataManager.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/24/25.
//

import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private let notesKey = "SavedNotes"
    private let currentPageKey = "CurrentPage"
    private let selectedColorKey = "SelectedNoteColor"
    
    private init() {}
    
    // MARK: - Notes Persistence
    
    func saveNotes(_ notes: [Note]) {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: notesKey)
        } catch {
            print("Failed to save notes: \(error)")
        }
    }
    
    func loadNotes() -> [Note] {
        guard let data = UserDefaults.standard.data(forKey: notesKey) else {
            // Return default notes if no saved data
            return createDefaultNotes()
        }
        
        do {
            let notes = try JSONDecoder().decode([Note].self, from: data)
            return notes.isEmpty ? createDefaultNotes() : notes
        } catch {
            print("Failed to load notes: \(error)")
            return createDefaultNotes()
        }
    }
    
    // MARK: - Current Page Persistence
    
    func saveCurrentPage(_ page: Int) {
        UserDefaults.standard.set(page, forKey: currentPageKey)
    }
    
    func loadCurrentPage() -> Int {
        return UserDefaults.standard.integer(forKey: currentPageKey)
    }
    
    // MARK: - Selected Color Persistence
    
    // Predefined colors that match NoteColorSettingsView
    private let predefinedColors: [Color] = [
        Color.yellow,                    // Classic yellow
        Color.orange,                    // Orange
        Color(red: 1.0, green: 0.6, blue: 0.6),  // Light coral
        Color(red: 0.6, green: 0.9, blue: 0.6),  // Light green
        Color(red: 0.6, green: 0.8, blue: 1.0),  // Light blue
        Color(red: 0.8, green: 0.6, blue: 1.0),  // Light purple
        Color(red: 1.0, green: 0.8, blue: 0.8),  // Light pink
        Color(red: 0.9, green: 0.7, blue: 0.6),  // Light brown
        Color(red: 0.9, green: 0.9, blue: 0.9),  // Light gray
        Color(red: 0.4, green: 0.6, blue: 0.4)   // Dark green
    ]
    
    func saveSelectedColor(_ color: Color) {
        // Find the closest matching predefined color and save its index
        let colorIndex = findClosestColorIndex(for: color)
        UserDefaults.standard.set(colorIndex, forKey: selectedColorKey)
    }
    
    func loadSelectedColor() -> Color {
        let colorIndex = UserDefaults.standard.integer(forKey: selectedColorKey)
        // Ensure index is within bounds
        if colorIndex >= 0 && colorIndex < predefinedColors.count {
            return predefinedColors[colorIndex]
        }
        return predefinedColors[0] // Default to yellow
    }
    
    // Helper function to find closest color match
    private func findClosestColorIndex(for color: Color) -> Int {
        let targetUIColor = UIColor(color)
        var targetRed: CGFloat = 0, targetGreen: CGFloat = 0, targetBlue: CGFloat = 0, targetAlpha: CGFloat = 0
        targetUIColor.getRed(&targetRed, green: &targetGreen, blue: &targetBlue, alpha: &targetAlpha)
        
        var closestIndex = 0
        var smallestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for (index, predefinedColor) in predefinedColors.enumerated() {
            let predefinedUIColor = UIColor(predefinedColor)
            var predefinedRed: CGFloat = 0, predefinedGreen: CGFloat = 0, predefinedBlue: CGFloat = 0, predefinedAlpha: CGFloat = 0
            predefinedUIColor.getRed(&predefinedRed, green: &predefinedGreen, blue: &predefinedBlue, alpha: &predefinedAlpha)
            
            // Calculate Euclidean distance in RGB space
            let distance = sqrt(
                pow(targetRed - predefinedRed, 2) +
                pow(targetGreen - predefinedGreen, 2) +
                pow(targetBlue - predefinedBlue, 2)
            )
            
            if distance < smallestDistance {
                smallestDistance = distance
                closestIndex = index
            }
        }
        
        return closestIndex
    }
    
    // MARK: - Default Data
    
    private func createDefaultNotes() -> [Note] {
        return [
            Note(text: "Speak it and Stick it. Never forget it!", position: CGPoint(x: 0, y: 0), rotation: -2),
            Note(text: "", position: CGPoint(x: 0, y: 0), rotation: 1.5),
            Note(text: "", position: CGPoint(x: 0, y: 0), rotation: -1),
            Note(text: "", position: CGPoint(x: 0, y: 0), rotation: 0.5),
            Note(text: "", position: CGPoint(x: 0, y: 0), rotation: -1.5),
            Note(text: "", position: CGPoint(x: 0, y: 0), rotation: 2),
            Note(text: "", position: CGPoint(x: 0, y: 0), rotation: -0.8),
            Note(text: "", position: CGPoint(x: 0, y: 0), rotation: 1.2)
        ]
    }
}