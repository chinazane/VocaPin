//
//  VocaPinWidgetEntryView.swift
//  VocaPinWidget
//
//  Created by Bill Zhang on 8/22/25.
//

import WidgetKit
import SwiftUI

struct VocaPinWidgetEntryView: View {
    var entry: NoteProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Cork board background
            Color(red: 0.9, green: 0.85, blue: 0.8)
            
            switch family {
            case .systemSmall:
                SmallWidgetView(note: entry.note)
            case .systemMedium:
                MediumWidgetView(note: entry.note)
            case .systemLarge:
                LargeWidgetView(note: entry.note)
            default:
                SmallWidgetView(note: entry.note)
            }
        }
    }
}

struct SmallWidgetView: View {
    let note: WidgetNote
    
    var body: some View {
        ZStack {
            // Note shadow
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.15))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: 2, y: 2)
            
            // Main note
            RoundedRectangle(cornerRadius: 8)
                .fill(note.color)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    VStack {
                        Spacer()
                        
                        Text(note.text.isEmpty ? "Tap to add note" : note.text)
                            .font(.custom("Marker Felt", size: 14))
                            .foregroundColor(note.text.isEmpty ? .black.opacity(0.4) : .black)
                            .multilineTextAlignment(.center)
                            .lineLimit(6)
                            .padding(.horizontal, 8)
                        
                        Spacer()
                    }
                )
        }
        .overlay(
            // Red pin
            VStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 11, height: 11)
                            .offset(x: -2, y: -2)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .offset(y: -8)
        )
        .rotationEffect(.degrees(note.rotation))
        .padding(8)
    }
}

struct MediumWidgetView: View {
    let note: WidgetNote
    
    var body: some View {
        HStack(spacing: 16) {
            // Main note
            ZStack {
                // Note shadow
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .offset(x: 3, y: 3)
                
                // Main note
                RoundedRectangle(cornerRadius: 12)
                    .fill(note.color)
                    .frame(width: 140, height: 140)
                    .overlay(
                        VStack {
                            Spacer()
                            
                            Text(note.text.isEmpty ? "Tap to add note" : note.text)
                                .font(.custom("Marker Felt", size: 16))
                                .foregroundColor(note.text.isEmpty ? .black.opacity(0.4) : .black)
                                .multilineTextAlignment(.center)
                                .lineLimit(8)
                                .padding(.horizontal, 12)
                            
                            Spacer()
                        }
                    )
            }
            .overlay(
                // Red pin
                VStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 14, height: 14)
                                .offset(x: -2, y: -2)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .offset(y: -10)
            )
            .rotationEffect(.degrees(note.rotation))
            
            // App info section
            VStack(alignment: .leading, spacing: 8) {
                Text("VocaPin")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Tap to open and edit your notes")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
    }
}

struct LargeWidgetView: View {
    let note: WidgetNote
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("VocaPin Notes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("Tap to edit")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.7))
            }
            
            // Large note
            ZStack {
                // Note shadow
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.15))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: 4, y: 4)
                
                // Main note
                RoundedRectangle(cornerRadius: 16)
                    .fill(note.color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        VStack {
                            Spacer()
                            
                            Text(note.text.isEmpty ? "Tap to add note" : note.text)
                                .font(.custom("Marker Felt", size: 24))
                                .foregroundColor(note.text.isEmpty ? .black.opacity(0.4) : .black)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Spacer()
                        }
                    )
            }
            .overlay(
                // Red pin
                VStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 20, height: 20)
                                .offset(x: -3, y: -3)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 3, x: 2, y: 2)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .offset(y: -14)
            )
            .rotationEffect(.degrees(note.rotation))
        }
        .padding(16)
    }
}