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
    
    func saveSelectedColor(_ color: Color) {
        let uiColor = UIColor(color)
        do {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            UserDefaults.standard.set(colorData, forKey: selectedColorKey)
        } catch {
            print("Failed to save selected color: \(error)")
        }
    }
    
    func loadSelectedColor() -> Color {
        guard let colorData = UserDefaults.standard.data(forKey: selectedColorKey),
              let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) else {
            return .yellow
        }
        return Color(uiColor)
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