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
                            .padding(.horizontal, 32)
                    }

                    VStack {
                        ForEach(whisperViewModel.unconfirmedText, id: \.self) { text in
                            Text(text)
                                .opacity(0.25)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 32)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(whisperViewModel.currentText.isEmpty ? " " : whisperViewModel.currentText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
                    .contentTransition(.interpolate)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(0.5)
                    .frame(minHeight: 100, alignment: .top)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 32)
            }
            .font(.system(size: 42))
            .fontWeight(.bold)
            .padding(.vertical, 24)
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
