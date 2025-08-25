//
//  PageIndicatorView.swift
//  VocaPin
//
//  Created by Bill Zhang on 8/22/25.
//

import SwiftUI

struct PageIndicatorView: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.yellow : Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

#Preview {
    PageIndicatorView(currentPage: 1, totalPages: 4)
}