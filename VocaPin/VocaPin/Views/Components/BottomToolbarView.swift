//
//  BottomToolbarView.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/22/25.
//

import SwiftUI

struct BottomToolbarView: View {
    @Binding var showColorSettings: Bool
    @Binding var showDeleteNote: Bool
    
    var body: some View {
        HStack {
            // Left button (color palette icon)
            Button(action: {
                showColorSettings = true
            }) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "paintpalette.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            }
            
            Spacer()
            
            // Center microphone button
            Button(action: {}) {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "mic.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
            
            // Right button (trash icon)
            Button(action: {
                showDeleteNote = true
            }) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.gray)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 30)
        .background(Color(red: 0.9, green: 0.85, blue: 0.8))
    }
}

#Preview {
    BottomToolbarView(showColorSettings: .constant(false), showDeleteNote: .constant(false))
}