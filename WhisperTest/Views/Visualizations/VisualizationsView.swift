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
        HStack {
            ForEach(whisperViewModel.displayedVisualizations) { visualization in
                switch visualization.visualizationType {
                case .plainText:
                    Text("Plain text: \(visualization.mainBody ?? "")")
                default:
                    Text("TODO!!")
                        .border(.red)
                }
            }
        }
    }
}
