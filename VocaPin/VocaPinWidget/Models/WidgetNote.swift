//
//  WidgetNote.swift
//  VocaPinWidget
//
//  Created by Bill Zhang on 8/22/25.
//

import SwiftUI

// Widget-compatible Note structure
struct WidgetNote: Codable {
    let text: String
    let colorRed: Double
    let colorGreen: Double
    let colorBlue: Double
    let rotation: Double
    
    var color: Color {
        Color(red: colorRed, green: colorGreen, blue: colorBlue)
    }
    
    init(text: String, color: Color, rotation: Double = 0) {
        self.text = text
        self.rotation = rotation
        
        // Convert SwiftUI Color to RGB components
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        self.colorRed = Double(red)
        self.colorGreen = Double(green)
        self.colorBlue = Double(blue)
    }
}

struct SampleNote {
    static let sample = WidgetNote(
        text: "Speak it and Stick it. Never forget it!",
        color: .yellow,
        rotation: -2
    )
}