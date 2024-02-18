//
//  WhisperVM+Testing.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/18/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI
import WhisperKit

extension WhisperViewModel {
    func startTestingScript() {
        let chunkLength = Float(2.0)
        let wordLength = Float(0.19)

        guard let testingConfiguration else { return }

        let chunked = testingConfiguration.mockTranscript.components(separatedBy: .newlines)

        Task {
            var previousChunk: String?

            func addPreviousChunk(currentIndex: Int) {
                let previousIndex = currentIndex - 1

                if let previousChunk {
                    let segment = TranscriptionSegment(
                        //                        id: index,
                        id: UUID().uuidString,
                        seek: 0,
                        start: Float(previousIndex) * chunkLength,
                        end: Float(currentIndex) * chunkLength,
                        text: previousChunk,
                        tokens: [],
                        temperature: 1,
                        avgLogprob: 1,
                        compressionRatio: 1,
                        noSpeechProb: 1
                    )

                    confirmedSegments.append(segment)

                    if testingConfiguration.useSnapshotsForVisualizations {
                        print("using index: \(previousIndex)")
                        if testingConfiguration.snapshots.indices.contains(previousIndex) {
                            let visualizations = testingConfiguration.snapshots[previousIndex].visualizations
                            displayVisualizations(visualizations: visualizations)
                        } else {
                            print("No visualizations??")
                            displayVisualizations(visualizations: [])
                        }
                    }
                }
            }

            for index in chunked.indices {
                let chunk = chunked[index]

                await { @MainActor in
                    if previousChunk != nil {
                        addPreviousChunk(currentIndex: index)
                    }

                    self.currentText = ""
                }()

                let words = chunk.components(separatedBy: .whitespaces)

                for wordIndex in words.indices {
                    await { @MainActor in
                        withAnimation {
                            self.currentText += "\(words[wordIndex]) "
                        }
                    }()

                    try await Task.sleep(for: .seconds(Double(wordLength)))
                }

                previousChunk = chunk

                try await Task.sleep(for: .seconds(0.3))
            }

            // last one

            await { @MainActor in
                withAnimation {
                    self.currentText = ""
                }
            }()

            try await Task.sleep(for: .seconds(0.5))

            await { @MainActor in
                withAnimation {
                    addPreviousChunk(currentIndex: chunked.count)
                }
            }()
        }
    }
}
