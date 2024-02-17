//
//  WhisperViewModel.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/17/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Files
import SwiftUI
import WhisperKit

class WhisperViewModel: ObservableObject {
    @Published var whisperKit: WhisperKit?
    var selectedModel = "base.en"
    
    // MARK: - Loading

    @Published var specializationProgress = Float(0)
    @Published var isLoading = false
}

extension WhisperViewModel {
    func loadModel() {
        print("Selected Model: \(selectedModel)")

        whisperKit = nil
        
        Task {
            let whisperKit = try await WhisperKit(
                verbose: true,
                logLevel: .debug,
                prewarm: false,
                load: false,
                download: false
            )
            
            await MainActor.run {
                self.whisperKit = whisperKit
            }
            
            do {
                let folder = try Folder(path: Bundle.main.resourcePath!)
                let modelFolder = try folder.subfolder(named: "openai_whisper-base.en")
                
                whisperKit.modelFolder = modelFolder.url
                
                // Prewarm models
                do {
                    try await whisperKit.prewarmModels()
                } catch {
                    print("Error pre-warming models: \(error.localizedDescription)")
                }
                
                await MainActor.run {
                    // Set the loading progress to 90% of the way after prewarm
                    isLoading = true
                }
                
                try await whisperKit.loadModels()
                
                await MainActor.run {
                    specializationProgress = 1.0
                    isLoading = false
                }
                
                print("Finished!")
            } catch {
                print("Couldn't get folder: \(error)")
            }
        }
    }
}
