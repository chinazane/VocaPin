//
//  CorkBoardBackground.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/22/25.
//

import SwiftUI

struct CorkBoardBackground: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.6, green: 0.4, blue: 0.2),
                        Color(red: 0.5, green: 0.3, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                // Cork texture dots
                Canvas { context, size in
                    let dotSize: CGFloat = 3
                    let spacing: CGFloat = 40
                    
                    for x in stride(from: 0, to: size.width, by: spacing) {
                        for y in stride(from: 0, to: size.height, by: spacing) {
                            let randomX = x + Double.random(in: -10...10)
                            let randomY = y + Double.random(in: -10...10)
                            
                            context.fill(
                                Path(ellipseIn: CGRect(
                                    x: randomX,
                                    y: randomY,
                                    width: dotSize,
                                    height: dotSize
                                )),
                                with: .color(Color(red: 0.4, green: 0.25, blue: 0.1).opacity(0.6))
                            )
                        }
                    }
                }
            )
    }
}

#Preview {
    CorkBoardBackground()
}