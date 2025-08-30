//
//  HeaderView.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/22/25.
//

import SwiftUI

struct HeaderView: View {
    @State private var showProfileSettings = false
    
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text("Notes.AI")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: {
                showProfileSettings = true
            }) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .background(Color(red: 0.9, green: 0.85, blue: 0.8))
        .fullScreenCover(isPresented: $showProfileSettings) {
            ProfileSettingsView()
        }
    }
}

#Preview {
    HeaderView()
}