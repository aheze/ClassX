//
//  VisualizationsView.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/18/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct VisualizationsView: View {
    @Environment(\.openWindow) var openWindow

    @ObservedObject var whisperViewModel: WhisperViewModel

    var body: some View {
        let displayedVisualizations: [Visualization] = {
            if let currentFocusedSegmentID = whisperViewModel.currentFocusedSegmentID {
                if let response = whisperViewModel.serverResponseBySegmentID[currentFocusedSegmentID] {
                    return response.visualizations.filter { $0.visualizationType != .bullet }
                }
            }

            return whisperViewModel.displayedVisualizations.filter { $0.visualizationType != .bullet }
        }()

        VStack(spacing: 0) {
            if displayedVisualizations.isEmpty {
                VStack(spacing: 64) {
                    Text("ClassX")
                        .font(.system(size: 48, weight: .medium, design: .monospaced))
                        .kerning(10)

                    Text("Sit tight while we make\nthis lecture more bearable!")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .drawingGroup()
                .padding(.horizontal, 24)
            } else {
                ForEach(displayedVisualizations) { visualization in

                    switch visualization.visualizationType {
                    case .latex:
                        contextButton(title: "Breakdown", color: .indigo, visualization: visualization)
                    case .url:
                        URLVisualization(urlString: visualization.mainBody ?? "")
                    case .image:
                        ImageVisualization(urlString: visualization.mainBody ?? "")
                    case .plainText:
                        contextButton(title: "More Context", color: .red, visualization: visualization)
                    case .bullet:
                        contextButton(title: "Further Reading", color: .purple, visualization: visualization)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring, value: displayedVisualizations.map { $0.id })
        .font(.system(size: 24))
    }

    func contextButton(title: String, color: Color, visualization: Visualization) -> some View {
        Button {
            openWindow(value: visualization)
        } label: {
            VStack(alignment: .leading, spacing: 30) {
                HStack {
                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 32))
                }

                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundColor(color)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.gradient)
                    .brightness(0.95)
                    .opacity(0.3)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 32)
        .padding(.vertical, 32)
    }
}
