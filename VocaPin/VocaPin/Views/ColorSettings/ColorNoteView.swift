//
//  ColorNoteView.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/22/25.
//

import SwiftUI

struct ColorNoteView: View {
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Shadow
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
                .frame(width: 120, height: 120)
                .offset(x: 3, y: 3)
            
            // Main note
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 120, height: 120)
                .overlay(
                    // Selection border
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: isSelected ? 3 : 0)
                )
            
            // Inner shadow note (for layered effect on some colors)
            if color != Color.yellow {
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.opacity(0.8))
                    .frame(width: 80, height: 80)
                    .offset(x: -10, y: 10)
            }
            
            // Selection checkmark
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .background(Color.white.clipShape(Circle()))
                    .offset(x: 40, y: -40)
            }
        }
        .scaleEffect(isSelected ? 1.0 : 0.9)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    HStack {
        ColorNoteView(color: .yellow, isSelected: false)
        ColorNoteView(color: .orange, isSelected: true)
    }
}