//
//  Note.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/22/25.
//

import Foundation
import SwiftUI

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var position: CGPoint
    var rotation: Double
    var color: Color
    
    // Predefined colors that match the color picker
    static let predefinedColors: [Color] = [
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
    
    // Custom coding keys to handle Color encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, text, position, rotation, colorIndex, colorData
    }
    
    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        position = try container.decode(CGPoint.self, forKey: .position)
        rotation = try container.decode(Double.self, forKey: .rotation)
        
        // Try to decode color index first (new format)
        if let colorIndex = try container.decodeIfPresent(Int.self, forKey: .colorIndex),
           colorIndex >= 0 && colorIndex < Self.predefinedColors.count {
            color = Self.predefinedColors[colorIndex]
        }
        // Fallback to old color data format for backward compatibility
        else if let colorData = try container.decodeIfPresent(Data.self, forKey: .colorData),
                let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            // Find closest matching predefined color
            let loadedColor = Color(uiColor)
            let closestIndex = Self.findClosestColorIndex(for: loadedColor)
            color = Self.predefinedColors[closestIndex]
        } else {
            color = Self.predefinedColors[0] // Default to yellow
        }
    }
    
    // Custom encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(position, forKey: .position)
        try container.encode(rotation, forKey: .rotation)
        
        // Encode color as index for precision
        let colorIndex = Self.findClosestColorIndex(for: color)
        try container.encode(colorIndex, forKey: .colorIndex)
    }
    
    // Helper function to find closest color match
    private static func findClosestColorIndex(for color: Color) -> Int {
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
    
    // Regular initializer
    init(text: String, position: CGPoint, rotation: Double, color: Color = .yellow) {
        self.id = UUID()
        self.text = text
        self.position = position
        self.rotation = rotation
        self.color = color
    }
    
    // Equatable conformance
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id &&
               lhs.text == rhs.text &&
               lhs.position == rhs.position &&
               lhs.rotation == rhs.rotation &&
               UIColor(lhs.color) == UIColor(rhs.color)
    }
}