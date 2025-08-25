//
//  NotebookEditingView.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/22/25.
//

import SwiftUI
import WidgetKit

struct NotebookEditingView: View {
    @Binding var isPresented: Bool
    @Binding var note: Note
    @State private var editingText: String = ""
    @FocusState private var isTextEditorFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Cork board background
                Color(red: 0.9, green: 0.85, blue: 0.8)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Navigation bar
                    HStack {
                        Button("Cancel") {
                            isPresented = false
                        }
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("Edit Note")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button("Done") {
                            note.text = editingText
                            // Force immediate widget sync when note is edited
                            WidgetCenter.shared.reloadAllTimelines()
                            isPresented = false
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    // Large sticky note for editing
                    ZStack {
                        // Note shadow
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.15))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .offset(x: 6, y: 6)
                        
                        // Main note
                        RoundedRectangle(cornerRadius: 16)
                            .fill(note.color)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(
                                VStack {
                                    Spacer()
                                    
                                    // Text editor
                                    TextEditor(text: $editingText)
                                        .font(.custom("Marker Felt", size: 28))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 20)
                                        .background(Color.clear)
                                        .scrollContentBackground(.hidden)
                                        .focused($isTextEditorFocused)
                                    
                                    Spacer()
                                }
                            )
                    }
                    .overlay(
                        // Red pin (head only, no needle)
                        VStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .fill(Color.white.opacity(0.4))
                                        .frame(width: 22, height: 22)
                                        .offset(x: -4, y: -4)
                                )
                                .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 2)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .offset(y: -16)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            editingText = note.text
            // Auto-focus the text editor when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextEditorFocused = true
            }
        }
    }
}

#Preview {
    NotebookEditingView(
        isPresented: .constant(true),
        note: .constant(Note(text: "Sample note text\nfor editing", position: CGPoint(x: 0, y: 0), rotation: 0))
    )
}
