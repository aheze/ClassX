//
//  WhisperViewModel.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/17/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import AVFoundation
import Files
import SwiftUI
import WhisperKit

enum LoadingState {
    case invalid
    case loading
    case done
}

class WhisperViewModel: ObservableObject {
    var whisperKit: WhisperKit?
    var selectedModel = "base.en"

    // MARK: - Loading

    @Published var specializationProgress = Float(0)
    @Published var loadingState = LoadingState.invalid

    // MARK: - Transcription

    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var testingText: String? = TestingData.script

    // MARK: - Configuration

    @AppStorage("fallbackCount") private var fallbackCount: Double = 4
    @AppStorage("compressionCheckWindow") private var compressionCheckWindow: Double = 20
    @AppStorage("sampleLength") private var sampleLength: Double = 224
    @AppStorage("silenceThreshold") private var silenceThreshold: Double = 0.3
    @AppStorage("useVAD") private var useVAD: Bool = true

    @Published var loadingProgressValue: Float = 0.0
    @Published var currentLag: TimeInterval = 0
    @Published var currentFallbacks: Int = 0
    @Published var lastBufferSize: Int = 0
    @Published var lastConfirmedSegmentEndSeconds: Float = 0
    @Published var requiredSegmentsForConfirmation: Int = 2
    @Published var confirmedSegments: [TranscriptionSegment] = []
    @Published var unconfirmedSegments: [TranscriptionSegment] = []
    @Published var unconfirmedText: [String] = []
    @Published var transcriptionTask: Task<Void, Never>? = nil
    @Published var currentText: String = ""
}

extension WhisperViewModel {
    func loadModel() {
        print("Selected Model: \(selectedModel)")

        whisperKit = nil

        startTestingScript()

        Task {
            let whisperKit = try await WhisperKit(
                verbose: true,
                logLevel: .debug,
                prewarm: false,
                load: false,
                download: false
            )

            await { @MainActor in
                self.whisperKit = whisperKit
            }()

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

                await { @MainActor in
                    loadingState = .loading
                }()

                try await whisperKit.loadModels()

                await { @MainActor in
                    specializationProgress = 1.0
                    loadingState = .done
                }()

                print("Finished!")
            } catch {
                print("Couldn't get folder: \(error)")

                await MainActor.run {
                    loadingState = .invalid
                }
            }
        }
    }

    func startTestingScript() {
        let chunkLength = Float(2.0)
        let wordLength = Float(0.19)

        guard let testingText else { return }

        let chunked = testingText.components(separatedBy: .newlines)

        Task {
            var previousChunk: String?

            func addPreviousChunk(index: Int) {
                if let previousChunk {
                    let segment = TranscriptionSegment(
                        id: index,
                        seek: 0,
                        start: Float(index - 1) * chunkLength,
                        end: Float(index) * chunkLength,
                        text: previousChunk,
                        tokens: [],
                        temperature: 1,
                        avgLogprob: 1,
                        compressionRatio: 1,
                        noSpeechProb: 1
                    )

                    confirmedSegments.append(segment)
                }
            }

            for index in chunked.indices {
                let chunk = chunked[index]

                await { @MainActor in
                    if previousChunk != nil {
                        addPreviousChunk(index: index)
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
                addPreviousChunk(index: chunked.count)

                withAnimation {
                    self.currentText = ""
                }
            }()
        }
    }
}

// MARK: - Transcription

extension WhisperViewModel {
    func toggle() {
        isRecording.toggle()

        if isRecording {
            startRecording()
        } else {
            resetState()
            stopRecording()
        }
    }

    func resetState() {
        isRecording = false
        isTranscribing = false
        whisperKit?.audioProcessor.stopRecording()
        currentText = ""
        unconfirmedText = []

        currentLag = 0
        currentFallbacks = 0
        lastBufferSize = 0
        lastConfirmedSegmentEndSeconds = 0
        requiredSegmentsForConfirmation = 2
        confirmedSegments = []
        unconfirmedSegments = []
    }

    func startRecording() {
        guard let whisperKit = whisperKit else { return }

        Task(priority: .userInitiated) {
//                guard await requestMicrophoneIfNeeded() else {
//                    print("Microphone access was not granted.")
//                    return
//                }

            try? whisperKit.audioProcessor.startRecordingLive { _ in
            }

            // Delay the timer start by 1 second
            isRecording = true
            isTranscribing = true
            realtimeLoop()
        }
    }

    func stopRecording() {
        guard let whisperKit = whisperKit else { return }
        whisperKit.audioProcessor.stopRecording()
    }

    func transcribeAudioSamples(_ samples: [Float]) async throws -> TranscriptionResult? {
        guard let whisperKit = whisperKit else { return nil }

        let languageCode = "en"
        let task: DecodingTask = .transcribe
        let seekClip = [lastConfirmedSegmentEndSeconds]

        let options = DecodingOptions(
            verbose: false,
            task: task,
            language: languageCode,
            temperatureFallbackCount: 3, // limit fallbacks for realtime
            sampleLength: Int(sampleLength), // reduced sample length for realtime
            skipSpecialTokens: true,
            clipTimestamps: seekClip
        )

        // Early stopping checks
        let decodingCallback: ((TranscriptionProgress) -> Bool?) = { progress in
            DispatchQueue.main.async {
                let fallbacks = Int(progress.timings.totalDecodingFallbacks)
                if progress.text.count < self.currentText.count {
                    if fallbacks == self.currentFallbacks {
                        self.unconfirmedText.append(self.currentText)
                    } else {
                        print("Fallback occured: \(fallbacks)")
                    }
                }
                self.currentText = progress.text
                self.currentFallbacks = fallbacks
            }
            // Check early stopping
            let currentTokens = progress.tokens
            let checkWindow = Int(self.compressionCheckWindow)
            if currentTokens.count > checkWindow {
                let checkTokens: [Int] = currentTokens.suffix(checkWindow)
                let compressionRatio = compressionRatio(of: checkTokens)
                if compressionRatio > options.compressionRatioThreshold! {
                    return false
                }
            }
            if progress.avgLogprob! < options.logProbThreshold! {
                return false
            }

            return nil
        }

        let transcription = try await whisperKit.transcribe(audioArray: samples, decodeOptions: options, callback: decodingCallback)
        return transcription
    }

    // MARK: Streaming Logic

    func realtimeLoop() {
        transcriptionTask = Task {
            while isRecording && isTranscribing {
                do {
                    try await transcribeCurrentBuffer()
                } catch {
                    print("Error: \(error.localizedDescription)")
                    break
                }
            }
        }
    }

    func transcribeCurrentBuffer() async throws {
        guard let whisperKit = whisperKit else { return }

        // Retrieve the current audio buffer from the audio processor
        let currentBuffer = whisperKit.audioProcessor.audioSamples

        // Calculate the size and duration of the next buffer segment
        let nextBufferSize = currentBuffer.count - lastBufferSize
        let nextBufferSeconds = Float(nextBufferSize) / Float(WhisperKit.sampleRate)

        // Only run the transcribe if the next buffer has at least 1 second of audio
        guard nextBufferSeconds > 1 else {
            await MainActor.run {
                if currentText == "" {
                    currentText = "Waiting for speech..."
                }
            }
            try await Task.sleep(nanoseconds: 100_000_000) // sleep for 100ms for next buffer
            return
        }

        if useVAD {
            // Retrieve the current relative energy values from the audio processor
            let currentRelativeEnergy = whisperKit.audioProcessor.relativeEnergy

            // Calculate the number of energy values to consider based on the duration of the next buffer
            // Each energy value corresponds to 1 buffer length (100ms of audio), hence we divide by 0.1
            let energyValuesToConsider = Int(nextBufferSeconds / 0.1)

            // Extract the relevant portion of energy values from the currentRelativeEnergy array
            let nextBufferEnergies = currentRelativeEnergy.suffix(energyValuesToConsider)

            // Determine the number of energy values to check for voice presence
            // Considering up to the last 1 second of audio, which translates to 10 energy values
            let numberOfValuesToCheck = max(10, nextBufferEnergies.count - 10)

            // Check if any of the energy values in the considered range exceed the silence threshold
            // This indicates the presence of voice in the buffer
            let voiceDetected = nextBufferEnergies.prefix(numberOfValuesToCheck).contains { $0 > Float(silenceThreshold) }

            // Only run the transcribe if the next buffer has voice
            guard voiceDetected else {
                await MainActor.run {
                    if currentText == "" {
                        currentText = "Waiting for speech..."
                    }
                }

                //                if nextBufferSeconds > 30 {
                //                    // This is a completely silent segment of 30s, so we can purge the audio and confirm anything pending
                //                    lastConfirmedSegmentEndSeconds = 0
                //                    whisperKit.audioProcessor.purgeAudioSamples(keepingLast: 2 * WhisperKit.sampleRate) // keep last 2s to include VAD overlap
                //                    currentBuffer = whisperKit.audioProcessor.audioSamples
                //                    lastBufferSize = 0
                //                    confirmedSegments.append(contentsOf: unconfirmedSegments)
                //                    unconfirmedSegments = []
                //                }

                // Sleep for 100ms and check the next buffer
                try await Task.sleep(nanoseconds: 100_000_000)
                return
            }
        }

        // Run transcribe
        lastBufferSize = currentBuffer.count

        let transcription = try await transcribeAudioSamples(Array(currentBuffer))

        // We need to run this next part on the main thread
        await MainActor.run {
            currentText = ""
            unconfirmedText = []
            guard let segments = transcription?.segments else {
                return
            }

//            self.tokensPerSecond = transcription?.timings?.tokensPerSecond ?? 0
//            self.realTimeFactor = transcription?.timings?.realTimeFactor ?? 0
//            self.firstTokenTime = transcription?.timings?.firstTokenTime ?? 0
//            self.pipelineStart = transcription?.timings?.pipelineStart ?? 0
//            self.currentLag = transcription?.timings?.decodingLoop ?? 0

            // Logic for moving segments to confirmedSegments
            if segments.count > requiredSegmentsForConfirmation {
                // Calculate the number of segments to confirm
                let numberOfSegmentsToConfirm = segments.count - requiredSegmentsForConfirmation

                // Confirm the required number of segments
                let confirmedSegmentsArray = Array(segments.prefix(numberOfSegmentsToConfirm))
                let remainingSegments = Array(segments.suffix(requiredSegmentsForConfirmation))

                // Update lastConfirmedSegmentEnd based on the last confirmed segment
                if let lastConfirmedSegment = confirmedSegmentsArray.last, lastConfirmedSegment.end > lastConfirmedSegmentEndSeconds {
                    lastConfirmedSegmentEndSeconds = lastConfirmedSegment.end

                    // Add confirmed segments to the confirmedSegments array
                    if !self.confirmedSegments.contains(confirmedSegmentsArray) {
                        self.confirmedSegments.append(contentsOf: confirmedSegmentsArray)
                    }
                }

                // Update transcriptions to reflect the remaining segments
                self.unconfirmedSegments = remainingSegments
            } else {
                // Handle the case where segments are fewer or equal to required
                self.unconfirmedSegments = segments
            }
        }
    }

    func requestMicrophoneIfNeeded() async -> Bool {
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)

        switch microphoneStatus {
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    continuation.resume(returning: granted)
                }
            }
        case .restricted, .denied:
            print("Microphone access denied")
            return false
        case .authorized:
            return true
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }
}
