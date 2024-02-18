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
        VStack(spacing: 0) {
            ForEach(Array(zip(whisperViewModel.displayedVisualizations.indices, whisperViewModel.displayedVisualizations)), id: \.1.id) { index, visualization in

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

                if index < whisperViewModel.displayedVisualizations.count - 1 {
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring, value: whisperViewModel.displayedVisualizations.map { $0.id })
        .font(.system(size: 38))
    }
}
