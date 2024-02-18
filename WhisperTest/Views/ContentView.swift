//
//  ContentView.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/17/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @StateObject var whisperViewModel = WhisperViewModel()

    var body: some View {
        VStack {
            if whisperViewModel.initial {
                ZStack {
                    VStack {
                        Text("ClassX")
                            .font(.system(size: 64, weight: .medium, design: .monospaced))
                            .kerning(10)

                        Button("Begin") {
                            withAnimation {
                                whisperViewModel.expanded = true
                            }
                        }
                    }
                    .opacity(whisperViewModel.expanded ? 0 : 1)

                    HStack(spacing: 20) {
                        Image(systemName: "1.circle.fill")
                            .font(.system(size: 64, weight: .medium))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Resize to fit the board!")
                                .font(.system(size: 44, weight: .medium))

                            Text("Drag the bottom-right corner")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 32, weight: .medium))
                        }
                    }
                    .opacity(whisperViewModel.expanded ? 1 : 0)
                }
                .padding(whisperViewModel.expanded ? 32 : 90)
                .frame(
                    maxWidth: whisperViewModel.expanded ? .infinity : nil,
                    maxHeight: whisperViewModel.expanded ? .infinity : nil
                )
                .overlay(alignment: .top) {
                    Text("Quick Setup")
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .font(.system(size: 32, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .overlay(alignment: .leading) {
                            Button {
                                withAnimation {
                                    whisperViewModel.expanded = false
                                }
                            } label: {
                                Image(systemName: "chevron.backward")
                                    .font(.system(size: 24, weight: .medium))
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(32)
                        .opacity(whisperViewModel.expanded ? 1 : 0)
                }
                .overlay(alignment: .bottomTrailing) {
                    Image("BottomRightArrow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .padding(64)
                        .rotationEffect(.degrees(16))
                        .opacity(whisperViewModel.expanded ? 1 : 0)
                }

            } else {
                switch whisperViewModel.loadingState {
                case .invalid, .loading:
                    ProgressView()
                        .scaleEffect(2)
                case .done:
                    Button(whisperViewModel.isRecording ? "Stop" : "Record") {
                        whisperViewModel.toggle()
                    }
                }
            }
//
//            Divider()
//
//            ScrollView {
//                LatexVisualization()
//            }
//
//            Divider()
//
//            HStack {
//                TranscriptView(whisperViewModel: whisperViewModel)
//                    .frame(maxHeight: 500)
//                    .padding()
//
//                VisualizationsView(whisperViewModel: whisperViewModel)
//            }
//
//            Button("Start") {
//                whisperViewModel.startTestingScript()
//            }
        }
        .glassBackgroundEffect()
//        .padding()
        .onAppear {
            whisperViewModel.loadModel()
        }
    }
}

// struct ContentView: View {
//    @StateObject var whisperViewModel = WhisperViewModel()
//
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//
//            Text("Hello, world!")
//
//            switch whisperViewModel.loadingState {
//            case .invalid:
//                Text("About to load")
//            case .loading:
//                ProgressView()
//            case .done:
//                Button(whisperViewModel.isRecording ? "Stop" : "Record") {
//                    whisperViewModel.toggle()
//                }
//            }
//
//            Divider()
//
//            ScrollView {
//                LatexVisualization()
//            }
//
//            Divider()
//
//
//            HStack {
//                TranscriptView(whisperViewModel: whisperViewModel)
//                    .frame(maxHeight: 500)
//                    .padding()
//
//                VisualizationsView(whisperViewModel: whisperViewModel)
//            }
//
//            Button("Start") {
//                whisperViewModel.startTestingScript()
//            }
//
//        }
//        .padding()
//        .onAppear {
//            whisperViewModel.loadModel()
//        }
//    }
// }

#Preview {
    ContentView()
}
