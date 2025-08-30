//
//  ContentView.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/22/25.
//

import SwiftUI
import WidgetKit

struct NotesView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var notes: [Note] = []
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var showColorSettings = false
    @State private var selectedNoteColor: Color = .yellow
    @State private var showNotebookEditing = false
    @State private var showDeleteNote = false
    @State private var showSpeechRecognition = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Cork board background
                CorkBoardBackground()
                
                VStack(spacing: 0) {
                    // Header
                    HeaderView()
                    
                    Spacer()
                    
                    // Notes area with swipe functionality
                    ZStack {
                        ForEach(Array(notes.enumerated()), id: \.element.id) { index, note in
                            StickyNoteView(
                                note: note,
                                isEditing: false,
                                editingText: .constant(""),
                                onTap: {
                                    if index == currentPage && !isDragging {
                                        showNotebookEditing = true
                                    }
                                }
                            )
                            .position(
                                x: geometry.size.width / 2 + note.position.x,
                                y: geometry.size.height / 2 + note.position.y - 80
                            )
                            .offset(x: CGFloat(index - currentPage) * geometry.size.width + dragOffset)
                            .scaleEffect(index == currentPage ? 1.0 : 0.8)
                            .opacity(index == currentPage ? 1.0 : 0.3)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                            .animation(.interactiveSpring(), value: dragOffset)
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                isDragging = false
                                let threshold: CGFloat = 100
                                
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    if value.translation.width > threshold && currentPage > 0 {
                                        // Swipe right - go to previous note
                                        currentPage -= 1
                                        dataManager.saveCurrentPage(currentPage)
                                    } else if value.translation.width < -threshold && currentPage < notes.count - 1 {
                                        // Swipe left - go to next note
                                        currentPage += 1
                                        dataManager.saveCurrentPage(currentPage)
                                    }
                                    dragOffset = 0
                                }
                            }
                    )
                    
                    Spacer()
                    
                    // Page indicators
                    PageIndicatorView(currentPage: currentPage, totalPages: notes.count)
                        .padding(.bottom, 20)
                    
                    // Bottom toolbar
                    BottomToolbarView(showColorSettings: $showColorSettings, showDeleteNote: $showDeleteNote, showSpeechRecognition: $showSpeechRecognition)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .fullScreenCover(isPresented: $showColorSettings) {
            NoteColorSettingsView(
                isPresented: $showColorSettings,
                selectedColor: currentPage < notes.count ? $notes[currentPage].color : $selectedNoteColor
            )
        }
        .fullScreenCover(isPresented: $showNotebookEditing) {
            NotebookEditingView(
                isPresented: $showNotebookEditing,
                note: $notes[currentPage]
            )
        }
        .fullScreenCover(isPresented: $showSpeechRecognition) {
            SpeechRecognitionView(isPresented: $showSpeechRecognition) { recognizedText in
                // Add recognized text to current note
                if currentPage < notes.count {
                    if notes[currentPage].text.isEmpty {
                        notes[currentPage].text = recognizedText
                    } else {
                        notes[currentPage].text += " " + recognizedText
                    }
                    dataManager.saveNotes(notes)
                    syncToWidget()
                }
            }
        }
        .overlay(
            // Delete note dialog
            Group {
                if showDeleteNote {
                    DeleteNoteView(
                        isPresented: $showDeleteNote,
                        note: notes[currentPage],
                        onDelete: {
                            deleteCurrentNote()
                        }
                    )
                }
            }
        )
        .onChange(of: selectedNoteColor) { newColor in
            // Update current note's color when color is selected
            if currentPage < notes.count {
                notes[currentPage].color = newColor
                dataManager.saveNotes(notes)
                dataManager.saveSelectedColor(newColor)
                // Update widget data
                syncToWidget()
            }
        }
        .onAppear {
            print("🎯 APP STARTED - ContentView onAppear called!")
            
            // Load saved data when view appears
            notes = dataManager.loadNotes()
            currentPage = dataManager.loadCurrentPage()
            selectedNoteColor = dataManager.loadSelectedColor()
            
            // Sync selectedNoteColor with current note's color
            if currentPage < notes.count {
                selectedNoteColor = notes[currentPage].color
            }
            
            print("📊 App: Loaded \(notes.count) notes, current page: \(currentPage)")
            
            // Ensure currentPage is within bounds
            if currentPage >= notes.count {
                currentPage = 0
                dataManager.saveCurrentPage(currentPage)
            }
            
            // Force immediate widget data sync
            print("🚀 App: About to sync data to widget")
            if currentPage < notes.count {
                print("📝 App: Current note text: '\(notes[currentPage].text)'")
            }
            
            // Test basic widget sync
            print("📤 App: Testing basic widget sync...")
            
            // Simple test - write a basic string
            if let appGroupDefaults = UserDefaults(suiteName: "group.vocappin.notes") {
                let testText = "TEST_FROM_APP_\(Date().timeIntervalSince1970)"
                appGroupDefaults.set(testText, forKey: "debug_test")
                appGroupDefaults.synchronize()
                print("✅ App: Saved debug test: '\(testText)'")
                
                // Verify immediate read
                if let readBack = appGroupDefaults.string(forKey: "debug_test") {
                    //print("✅ App: Immediate read verification: '\(readBack)'")
                } else {
                    //print("❌ App: Failed immediate read verification")
                }
            }
            
            // Simple fallback approach
            if currentPage < notes.count {
                let currentNote = notes[currentPage]
                
                // Try direct UserDefaults approach
                if let appGroupDefaults = UserDefaults(suiteName: "group.vocappin.notes") {
                    let simpleData = [
                        "text": currentNote.text,
                        "timestamp": Date().timeIntervalSince1970
                    ] as [String: Any]
                    
                    appGroupDefaults.set(simpleData, forKey: "simple_current_note")
                    appGroupDefaults.synchronize()
                   // print("✅ App: Saved simple data to App Group")
                } else {
                    //print("❌ App: App Group UserDefaults failed")
                }
            }
            
            // Also try WidgetDataManager
            WidgetDataManager.shared.saveNotes(notes, currentIndex: currentPage)
            
            // Test: Verify data was written correctly
            if let appGroupDefaults = UserDefaults(suiteName: "group.vocappin.notes") {
                if let testData = appGroupDefaults.dictionary(forKey: "currentNote"),
                   let testText = testData["text"] as? String {
                   // print("🔍 App: Verification - Data in App Group: '\(testText)'")
                } else {
                   // print("❌ App: Verification - No data found in App Group after save")
                }
            }
        }
        .onChange(of: notes) { _ in
            // Save notes whenever they change
            dataManager.saveNotes(notes)
            // Update widget data
            syncToWidget()
        }
        .onChange(of: currentPage) { _ in
            // Update widget when current page changes
            syncToWidget()
            // Sync selectedNoteColor with current note's color
            if currentPage < notes.count {
                selectedNoteColor = notes[currentPage].color
            }
        }
    }
    
    private func deleteCurrentNote() {
        // Clear the text content of the current note
        // This will make it show the placeholder "Tap to add note"
        notes[currentPage].text = ""
        dataManager.saveNotes(notes)
        // Update widget data
        syncToWidget()
    }
    

    
    private func syncToWidget() {
       // print("📤 App: syncToWidget called")
       /* print("📝 App: About to sync note at index \(currentPage): '\(currentPage < notes.count ? notes[currentPage].text : "INVALID INDEX")'")*/
        
        WidgetDataManager.shared.saveNotes(notes, currentIndex: currentPage)
        
        // Force widget reload immediately with multiple approaches
        WidgetCenter.shared.reloadAllTimelines()
        
        // Also try reloading specific widget kind
        WidgetCenter.shared.reloadTimelines(ofKind: "VocaPinWidget")
        
       // print("🔄 App: Forced widget reload with multiple methods")
        
        // Verify the save worked
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let appGroupDefaults = UserDefaults(suiteName: "group.vocappin.notes"),
               let testData = appGroupDefaults.dictionary(forKey: "currentNote"),
               let testText = testData["text"] as? String {
               // print("✅ App: Post-sync verification - Data in App Group: '\(testText)'")
            } else {
               // print("❌ App: Post-sync verification - No data found in App Group")
            }
        }
    }

}



#Preview {
    NotesView()
}
