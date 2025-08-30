//
//  WidgetSetupView.swift
//  VocaPin
//
//  Created by Kiro on 8/30/25.
//

import SwiftUI

struct WidgetSetupView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background - light blue with opacity
                Color.blue.opacity(0.15)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        Text("Widget Setup!")
                            .font(.custom("Marker Felt", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                        
                        // Subtitle
                        Text("Just a few steps to get your widget\non the home screen:")
                            .font(.custom("Marker Felt", size: 18))
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                        
                        // Steps
                        VStack(alignment: .leading, spacing: 16) {
                            StepView(number: "1.", text: "Long press on your home screen")
                            StepView(number: "2.", text: "Tap the '+' button in the top corner")
                            StepView(number: "3.", text: "Search for 'VocaPin'")
                            StepView(number: "4.", text: "Pick your favorite widget size")
                            StepView(number: "5.", text: "Tap 'Add Widget' & you're set!")
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        
                        // Got it button
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Got it!")
                                .font(.custom("Marker Felt", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .underline()
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
}

// MARK: - Step View Component
private struct StepView: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.custom("Marker Felt", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(width: 25, alignment: .leading)
            
            Text(text)
                .font(.custom("Marker Felt", size: 20))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    WidgetSetupView()
}
