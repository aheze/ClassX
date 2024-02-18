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
                        
                        Button {
                            if whisperViewModel.currentFocusedSegmentID == confirmedSegment.id {
                                whisperViewModel.currentFocusedSegmentID = nil
                            } else {
                                whisperViewModel.currentFocusedSegmentID = confirmedSegment.id
                            }
                        } label: {
                            Text(confirmedSegment.text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
                                .foregroundColor(whisperViewModel.currentFocusedSegmentID == confirmedSegment.id ? .green : .white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 32)
                        }
                        .buttonStyle(.plain)
                    }

                    VStack {
                        ForEach(whisperViewModel.unconfirmedText, id: \.self) { text in
                            Text(text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
                                .opacity(0.25)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 32)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                let currentText = whisperViewModel.currentText.trimmingCharacters(in: .whitespacesAndNewlines)

                Text(currentText.isEmpty ? " " : currentText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
                    .contentTransition(.interpolate)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(0.5)
                    .frame(minHeight: 100, alignment: .top)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 32)
                    .frame(height: currentText.isEmpty ? 0 : nil, alignment: .top)
            }
            .animation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 1), value: whisperViewModel.currentText)
            .animation(.spring, value: whisperViewModel.confirmedSegments.count)
            .font(.system(size: 32))
            .fontWeight(.bold)
            .padding(.vertical, 18)
            .rotationEffect(Angle(degrees: 180)).scaleEffect(x: -1.0, y: 1.0)
        }
        .rotationEffect(Angle(degrees: 180)).scaleEffect(x: -1.0, y: 1.0)
        .background {
            RoundedRectangle(cornerRadius: 36)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 6)
        }
    }
}
