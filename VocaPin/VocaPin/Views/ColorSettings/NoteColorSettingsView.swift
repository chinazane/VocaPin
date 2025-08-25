//
//  NoteColorSettingsView.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/22/25.
//

import SwiftUI

struct NoteColorSettingsView: View {
    @Binding var isPresented: Bool
    @Binding var selectedColor: Color
    
    @State private var selectedColorIndex: Int = 0
    
    let noteColors: [Color] = [
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
    
    var body: some View {
        ZStack {
            // Background matching main app
            Color(red: 0.9, green: 0.85, blue: 0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Note Color")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Invisible spacer to balance the X button
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Color grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(Array(noteColors.enumerated()), id: \.offset) { index, color in
                        ColorNoteView(color: color, isSelected: index == selectedColorIndex)
                            .onTapGesture {
                                selectedColorIndex = index
                            }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Done button
                Button(action: {
                    selectedColor = noteColors[selectedColorIndex]
                    isPresented = false
                }) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red)
                        .frame(height: 50)
                        .overlay(
                            Text("Done")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Set initial selection based on current color
            if let index = noteColors.firstIndex(of: selectedColor) {
                selectedColorIndex = index
            }
        }
    }
}

#Preview {
    NoteColorSettingsView(isPresented: .constant(true), selectedColor: .constant(.yellow))
}