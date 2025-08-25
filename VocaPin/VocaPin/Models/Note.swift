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
    
    // Custom coding keys to handle Color encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, text, position, rotation, colorData
    }
    
    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        position = try container.decode(CGPoint.self, forKey: .position)
        rotation = try container.decode(Double.self, forKey: .rotation)
        
        // Decode color from stored color data
        if let colorData = try container.decodeIfPresent(Data.self, forKey: .colorData),
           let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(uiColor)
        } else {
            color = .yellow
        }
    }
    
    // Custom encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(position, forKey: .position)
        try container.encode(rotation, forKey: .rotation)
        
        // Encode color as data
        let uiColor = UIColor(color)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .colorData)
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