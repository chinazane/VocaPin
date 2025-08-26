//
//  AudioWaveView.swift
//  VocaPin
//
//  Created by Kiro on 8/26/25.
//

import SwiftUI

struct AudioWaveView: View {
    let isRecording: Bool
    let audioLevel: Float
    let smoothedAudioLevel: Float
    let peakAudioLevel: Float
    let waveformData: [Float] // Real waveform data from audio buffer
    
    @State private var waveHeights: [CGFloat] = Array(repeating: 2, count: 50)
    
    // Enhanced wave properties
    private let maxWaveHeight: CGFloat = 60
    private let minWaveHeight: CGFloat = 2
    private let waveCount = 50
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<waveHeights.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.blue)
                    .frame(width: 3, height: waveHeights[index])
                    .animation(.easeInOut(duration: 0.1), value: waveHeights[index])
            }
        }
        .onAppear {
            updateWaveHeights()
        }
        .onChange(of: isRecording) { recording in
            if !recording {
                // When recording stops, immediately go to baseline
                withAnimation(.easeOut(duration: 0.3)) {
                    waveHeights = Array(repeating: minWaveHeight, count: waveCount)
                }
            }
        }
        .onChange(of: waveformData) { _ in
            // Update wave heights when real waveform data changes
            updateWaveHeights()
        }
    }
    

    
    private func updateWaveHeights() {
        if isRecording && !waveformData.isEmpty {
            // Use real audio data when recording and data is available
            let newHeights = calculateRealtimeWaveformFromData()
            
            // Quick, responsive animation for real audio data
            withAnimation(.easeInOut(duration: 0.05)) {
                waveHeights = newHeights
            }
        } else {
            // Not recording or no data - show baseline
            withAnimation(.easeOut(duration: 0.2)) {
                waveHeights = Array(repeating: minWaveHeight, count: waveCount)
            }
        }
    }
    
    // MARK: - Enhanced Wave Calculation Methods
    
    private func calculateRealtimeWaveformFromData() -> [CGFloat] {
        var heights: [CGFloat] = []
        
        // Use real waveform data - this should directly reflect microphone input
        if !waveformData.isEmpty && waveformData.count == waveCount {
            for i in 0..<waveCount {
                let dataValue = waveformData[i]
                
                // Convert normalized audio data (0.0 to 1.0) to visual height
                // Use a more linear approach to preserve the dynamic range
                let visualHeight = CGFloat(dataValue) * (maxWaveHeight - minWaveHeight)
                
                // Add minimum height for baseline visibility
                let finalHeight = minWaveHeight + visualHeight
                
                heights.append(finalHeight)
            }
            

        } else {
            // No real data available - show baseline (silence)
            heights = Array(repeating: minWaveHeight, count: waveCount)
        }
        
        return heights
    }
    

}

#Preview {
    AudioWaveView(
        isRecording: true, 
        audioLevel: 0.5, 
        smoothedAudioLevel: 0.4, 
        peakAudioLevel: 0.7,
        waveformData: Array(repeating: 0.3, count: 50)
    )
    .frame(height: 80)
    .background(Color.black)
}