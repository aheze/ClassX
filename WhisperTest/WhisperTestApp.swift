//
//  WhisperTestApp.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/17/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

@main
struct WhisperTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.plain)
        
        WindowGroup(for: Visualization.self) { $visualization in
            if let visualization {
                VisualizationDetail(visualization: visualization)
            }
        }
        .defaultSize(width: 900, height: 700)
    }
}
