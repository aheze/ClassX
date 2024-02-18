//
//  ContentView.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/17/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

enum Step {
    case initial
    case resizingToFitBoard
    case resizingToAddContent
    case finished
}

struct ContentView: View {
    @StateObject var whisperViewModel = WhisperViewModel()

    @State var step = Step.initial
    @State var allowShowNext = false
    @State var showingNext = false

    var body: some View {
//        VStack {
        ZStack {
            VStack {
                Text("ClassX")
                    .font(.system(size: 64, weight: .medium, design: .monospaced))
                    .kerning(10)

                Button {
                    step = .resizingToFitBoard

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        allowShowNext = true
                    }

                } label: {
                    Text("Begin")
                        .font(.system(size: 48, weight: .medium))
                        .padding(.horizontal, 38)
                        .padding(.vertical, 24)
                        .background(
                            Capsule()
                                .fill(.blue.opacity(0.5))
                        )
                }
                .buttonStyle(.plain)
            }
            .opacity(step == .initial ? 1 : 0)

            VStack(spacing: 48) {
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

                if showingNext {
                    Button {
                        step = .resizingToAddContent
                    } label: {
                        Text("Next")
                            .font(.system(size: 48, weight: .medium))
                            .padding(.horizontal, 38)
                            .padding(.vertical, 24)
                            .background(
                                Capsule()
                                    .fill(.blue.opacity(0.5))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .opacity(step == .resizingToFitBoard ? 1 : 0)
        }
        .padding(step == .initial ? 90 : 32)
        .frame(
            maxWidth: step == .initial ? nil : .infinity,
            maxHeight: step == .initial ? nil : .infinity
        )
        .glassBackgroundEffect(displayMode: .always)
        .overlay {
            RoundedRectangle(cornerRadius: 36)
                .strokeBorder(Color.blue, lineWidth: 16)
                .reverseMask {
                    ZStack {
                        Rectangle()
                            .padding(.vertical, 120)

                        Rectangle()
                            .padding(.horizontal, 120)
                    }
                }
                .opacity(step == .resizingToFitBoard ? 1 : 0)
        }
        .sizeReader { _ in
            guard allowShowNext else { return }

            if step == .resizingToFitBoard {
                withAnimation {
                    showingNext = true
                }
            }
        }
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
                            step = .initial
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 24, weight: .medium))
                    }
                    .buttonStyle(.borderless)
                }
                .padding(32)
                .opacity(step == .resizingToFitBoard ? 1 : 0)
        }
        .overlay(alignment: .bottomTrailing) {
            Image("BottomRightArrow")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .padding(64)
                .rotationEffect(.degrees(16))
                .opacity(showingNext ? 0.5 : 1)
                .opacity(step == .resizingToFitBoard ? 1 : 0)
        }
        .animation(.spring, value: step)

//        } else {
//            switch whisperViewModel.loadingState {
//            case .invalid, .loading:
//                ProgressView()
//                    .scaleEffect(2)
//            case .done:
//                Button(whisperViewModel.isRecording ? "Stop" : "Record") {
//                    whisperViewModel.toggle()
//                }
//            }
//        }
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
