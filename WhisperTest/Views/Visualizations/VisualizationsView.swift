//
//  VisualizationsView.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/18/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct VisualizationsView: View {
    @ObservedObject var whisperViewModel: WhisperViewModel

    var body: some View {
        let displayedVisualizations: [Visualization] = {
            if let currentFocusedSegmentID = whisperViewModel.currentFocusedSegmentID {
                if let response = whisperViewModel.serverResponseBySegmentID[currentFocusedSegmentID] {
                    return response.visualizations
                }
            }

            return whisperViewModel.displayedVisualizations
        }()

        VStack(spacing: 0) {
            if displayedVisualizations.isEmpty {
                VStack(spacing: 64) {
                    Text("ClassX")
                        .font(.system(size: 64, weight: .medium, design: .monospaced))
                        .kerning(10)

                    Text("Sit tight while we make\nthis lecture more bearable!")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .drawingGroup()
                .padding(.horizontal, 24)
            } else {
                ForEach(Array(zip(displayedVisualizations.indices, displayedVisualizations)), id: \.1.id) { index, visualization in

                    switch visualization.visualizationType {
                    case .latex:
                        LatexVisualization(string: visualization.mainBody ?? "")
                    case .url:
                        URLVisualization(urlString: visualization.mainBody ?? "")
                    case .image:
                        ImageVisualization(urlString: visualization.mainBody ?? "")
                    case .plainText:
                        Text(visualization.mainBody ?? "")
                            .padding(.horizontal, 32)
                            .padding(.vertical, 24)
                    case .bullet:
                        Text(visualization.mainBody ?? "")
                            .padding(.horizontal, 32)
                            .padding(.vertical, 24)
                    }

                    if index < displayedVisualizations.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring, value: displayedVisualizations.map { $0.id })
        .font(.system(size: 38))
    }
}
