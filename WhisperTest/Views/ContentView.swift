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

    @State var allowShowAddContentNext = false
    @State var showingAddContentNext = false

    @State var currentBoardSize = CGSize.zero
    @State var preservedBoardDimensions: CGSize?

    var body: some View {
        Color.clear
            .sizeReader { size in
                currentBoardSize = size
                if allowShowNext {
                    if step == .resizingToFitBoard {
                        withAnimation {
                            showingNext = true
                        }
                    }
                }

                if allowShowAddContentNext {
                    if step == .resizingToAddContent {
                        withAnimation {
                            showingAddContentNext = true
                        }
                    }
                }
            }
            .background {
                let (maxWidth, maxHeight): (CGFloat, CGFloat) = {
                    switch step {
                    case .initial:
                        return (600, 400)
                    case .resizingToAddContent:
                        return (680, 160)
                    default:
                        return (.infinity, .infinity)
                    }
                }()

                Color.clear
                    .glassBackgroundEffect()
                    .frame(
                        maxWidth: maxWidth,
                        maxHeight: maxHeight
                    )
//                    .padding(.horizontal, horizontalPadding)
//                    .opacity(step == .resizingToAddContent ? 0 : 1)
            }
            .background {
                backgroundSkeletonView
            }
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
            .overlay(alignment: .top) {
                topView
            }
            .overlay(alignment: .bottomTrailing) {
                bottomRightArrow
            }
            .overlay {
                ZStack {
                    initialView
                        .opacity(step == .initial ? 1 : 0)

                    stepView
                        .opacity(step == .resizingToFitBoard || step == .resizingToAddContent ? 1 : 0)
                }
                .padding(step == .initial ? 90 : 32)
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

    var initialView: some View {
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
    }

    var backgroundSkeletonView: some View {
        Color.clear
            .overlay {
                Color.clear
                    .frame(width: preservedBoardDimensions?.width, height: preservedBoardDimensions?.height)
                    .overlay(align: .leading, to: .trailing) {
                        RoundedRectangle(cornerRadius: 36)
                            .fill(.white)
                            .opacity(0.2)
                            .overlay {
                                RoundedRectangle(cornerRadius: 36)
                                    .strokeBorder(Color.blue, lineWidth: 16)
                            }
                            .frame(width: 500)
                            .offset(x: 80)
                    }
                    .overlay(align: .trailing, to: .leading) {
                        RoundedRectangle(cornerRadius: 36)
                            .fill(.white)
                            .opacity(0.2)
                            .overlay {
                                RoundedRectangle(cornerRadius: 36)
                                    .strokeBorder(Color.blue, lineWidth: 16)
                            }
                            .frame(width: 500)
                            .offset(x: -80)
                    }
            }
            .mask {
                HStack(spacing: 0) {
                    LinearGradient(colors: [.clear, .white], startPoint: .leading, endPoint: .trailing)
                    Color.white
                        .frame(width: preservedBoardDimensions?.width)
                    LinearGradient(colors: [.white, .clear], startPoint: .leading, endPoint: .trailing)
                }
            }
            .opacity(step == .resizingToAddContent ? 1 : 0)
    }

    var topView: some View {
        Text("Quick Setup")
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .font(.system(size: 32, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .overlay(alignment: .leading) {
                Button {
                    withAnimation {
                        preservedBoardDimensions = nil

                        if step == .resizingToAddContent {
                            step = .resizingToFitBoard
                        } else {
                            step = .initial
                        }
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 24, weight: .medium))
                }
                .buttonStyle(.borderless)
            }
            .padding(32)
            .opacity(step == .resizingToFitBoard || step == .resizingToAddContent ? 1 : 0)
    }

    var stepView: some View {
        VStack(spacing: 48) {
            HStack(spacing: 20) {
                Image(systemName: step == .resizingToAddContent ? "2.circle.fill" : "1.circle.fill")
                    .font(.system(size: 64, weight: .medium))

                VStack(alignment: .leading, spacing: 4) {
                    Text(step == .resizingToAddContent ? "Augment the board!" : "Resize to fit the board!")
                        .font(.system(size: 44, weight: .medium))

                    Text("Drag the bottom-right corner")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 32, weight: .medium))
                }
            }
            .offset(x: -20)
            .transition(.asymmetric(insertion: .offset(y: 40), removal: .offset(y: -40)).combined(with: .opacity))
            .id(step == .resizingToAddContent)

            if showingNext, step == .resizingToFitBoard {
                Button {
                    step = .resizingToAddContent
                    allowShowAddContentNext = true
                    preservedBoardDimensions = currentBoardSize
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

//            if showingAddContentNext, step == .resizingToAddContent {
//                Button {
//                    step = .finished
//                } label: {
//                    Text("Next")
//                        .font(.system(size: 48, weight: .medium))
//                        .padding(.horizontal, 38)
//                        .padding(.vertical, 24)
//                        .background(
//                            Capsule()
//                                .fill(.blue.opacity(0.5))
//                        )
//                }
//                .buttonStyle(.plain)
//            }
        }
    }

    var bottomRightArrow: some View {
        ZStack(alignment: .bottomTrailing) {
            Image("BottomRightArrow")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .padding(64)
                .rotationEffect(.degrees(16))
                .opacity(showingNext ? 0.5 : 1)
                .opacity(step == .resizingToFitBoard ? 1 : 0)

            Image(systemName: "arrow.right")
                .font(.system(size: 64))
                .frame(width: 120, height: 120)
                .background {
                    Color.blue
                        .opacity(0.3)
                        .brightness(0.5)
                }
                .glassBackgroundEffect(in: Circle())
                .offset(x: step == .resizingToAddContent ? 0 : -500)
                .opacity(step == .resizingToAddContent ? 1 : 0)
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
