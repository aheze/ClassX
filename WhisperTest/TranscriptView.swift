//
//  TranscriptView.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/17/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct TranscriptView: View {
    @ObservedObject var whisperViewModel: WhisperViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(whisperViewModel.confirmedSegments, id: \.id) { confirmedSegment in
                        Text("\(confirmedSegment.text)")
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                    }
                    
                    ForEach(whisperViewModel.unconfirmedSegments, id: \.id) { segment in
                        Text(segment.text)
                            .opacity(0.25)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                    }
                    
                    VStack {
                        ForEach(whisperViewModel.unconfirmedText, id: \.self) { text in
                            Text(text)
                                .opacity(0.25)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                        }
                    }
                }
                
                VStack {
                    Text(whisperViewModel.currentText)
                        .contentTransition(.interpolate)
                        .opacity(0.5)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                }
                .geometryGroup()
            }
            .font(.title3)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 24)
            .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1), value: whisperViewModel.confirmedSegments.count)
            .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1), value: whisperViewModel.currentText)
        }
        .background {
            RoundedRectangle(cornerRadius: 36)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 6)
        }
    }
}
