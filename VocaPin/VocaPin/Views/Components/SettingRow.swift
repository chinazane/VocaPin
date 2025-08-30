//
//  SettingRow.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/27/25.
//

import SwiftUI

enum SettingAction {
    case toggle(Binding<Bool>)
    case navigation(() -> Void)
}

struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: SettingAction
    let backgroundColor: Color
    let iconColor: Color
    
    init(icon: String, title: String, subtitle: String, action: SettingAction, backgroundColor: Color = .white, iconColor: Color = .gray) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with colored circle background
            ZStack {
                Circle()
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .accessibilityHidden(true)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Action
            switch action {
            case .toggle(let binding):
                Toggle("", isOn: binding)
                    .labelsHidden()
                    .accessibilityLabel("\(title) toggle")
                    .accessibilityValue(binding.wrappedValue ? "On" : "Off")
                
            case .navigation(let handler):
                Button(action: handler) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .accessibilityLabel("Navigate to \(title)")
            }
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

#Preview {
    VStack(spacing: 16) {
        SettingRow(
            icon: "apps.iphone",
            title: "Add Widget",
            subtitle: "Quick access from home.",
            action: .toggle(.constant(true)),
            backgroundColor: Color.blue.opacity(0.15),
            iconColor: Color.blue
        )
        
        SettingRow(
            icon: "globe",
            title: "Language",
            subtitle: "English",
            action: .navigation({}),
            backgroundColor: Color.green.opacity(0.15),
            iconColor: Color.green
        )
        
        SettingRow(
            icon: "star.fill",
            title: "Rate the App",
            subtitle: "Share your feedback.",
            action: .navigation({}),
            backgroundColor: Color.pink.opacity(0.15),
            iconColor: Color.pink
        )
    }
    .padding()
    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
}