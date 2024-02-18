//
//  DetailVisualization.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/18/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct VisualizationDetail: View {
    @Environment(\.dismissWindow) var dismissWindow

    var visualization: Visualization

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                Button {
                    dismissWindow()
                } label: {
                    Image(systemName: "xmark")
                        .padding()
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 14)

            ScrollView {
                VStack {
                    switch visualization.visualizationType {
                    case .latex:
                        LatexVisualization(string: visualization.mainBody ?? "")
                    default:
                        if let mainBody = visualization.mainBody {
                            Text(mainBody)
                        }
                    }
                }
                .font(.system(size: 24))
                .padding(.horizontal, 32)
                .padding(.vertical, 48)
                .frame(maxWidth: 700, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
        }
    }
}
