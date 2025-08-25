//
//  Provider.swift
//  VocaPinWidget
//
//  Created by Bill Zhang on 8/22/25.
//

import WidgetKit
import SwiftUI

struct NoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> NoteEntry {
        NoteEntry(date: Date(), note: SampleNote.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (NoteEntry) -> ()) {
        let entry = NoteEntry(date: Date(), note: SampleNote.sample)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NoteEntry>) -> ()) {
        var entries: [NoteEntry] = []

        // Get the current note from UserDefaults or use sample
        let currentNote = loadCurrentNote()
        
        // Generate a timeline consisting of one entry for now
        let currentDate = Date()
        let entry = NoteEntry(date: currentDate, note: currentNote)
        entries.append(entry)

        // Update timeline more frequently for development
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadCurrentNote() -> WidgetNote {
        //print("🔍 Widget Provider: Starting to load current note...")
        
        // Try App Group UserDefaults first
        if let appGroupDefaults = UserDefaults(suiteName: "group.vocappin.notes") {
            
            // Debug: List all keys in App Group
            let allKeys = appGroupDefaults.dictionaryRepresentation().keys
             // Try dictionary format (new format)
            if let noteData = appGroupDefaults.dictionary(forKey: "currentNote") {
               // print("🔍 Widget Provider: Found currentNote dictionary: \(noteData)")
                
                if let text = noteData["text"] as? String,
                   let colorRed = noteData["colorRed"] as? Double,
                   let colorGreen = noteData["colorGreen"] as? Double,
                   let colorBlue = noteData["colorBlue"] as? Double,
                   let rotation = noteData["rotation"] as? Double {
                    
                    let color = Color(red: colorRed, green: colorGreen, blue: colorBlue)
                    let note = WidgetNote(text: text, color: color, rotation: rotation)
                    return note
                } else {
                    print("❌ Widget Provider: Dictionary missing required fields")
                }
            } else {
                print("⚠️ Widget Provider: No currentNote dictionary found")
            }
            
            // Try legacy WidgetNote data
            if let data = appGroupDefaults.data(forKey: "currentNote") {
                //print("🔍 Widget Provider: Found currentNote data, trying to decode...")
                if let note = try? JSONDecoder().decode(WidgetNote.self, from: data) {
                    return note
                } else {
                    print("❌ Widget Provider: Failed to decode legacy data")
                }
            }
            
            // Try simple data fallback
            if let simpleData = appGroupDefaults.dictionary(forKey: "simple_current_note"),
               let text = simpleData["text"] as? String {
                return WidgetNote(text: text, color: .yellow, rotation: -2)
            }
        } else {
            print("❌ Widget Provider: App Group UserDefaults failed")
        }
        
        // Fallback to standard UserDefaults
        if let noteData = UserDefaults.standard.dictionary(forKey: "widget_currentNote"),
           let text = noteData["text"] as? String,
           let colorRed = noteData["colorRed"] as? Double,
           let colorGreen = noteData["colorGreen"] as? Double,
           let colorBlue = noteData["colorBlue"] as? Double,
           let rotation = noteData["rotation"] as? Double {
            
            let color = Color(red: colorRed, green: colorGreen, blue: colorBlue)
            let note = WidgetNote(text: text, color: color, rotation: rotation)
            return note
        }
        
        return SampleNote.sample
    }
}

struct NoteEntry: TimelineEntry {
    let date: Date
    let note: WidgetNote
}
