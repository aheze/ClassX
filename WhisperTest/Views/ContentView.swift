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
    @State var circleAnimations = [UUID]()

    @State var animatingBlur = false

    let minimumSideWidth = CGFloat(260)

    var body: some View {
        let shown: Bool = {
            if let preservedBoardDimensions {
                let shownRaw = step == .resizingToAddContent || step == .finished
                let enoughWidth = currentBoardSize.width > preservedBoardDimensions.width + minimumSideWidth * 2
                let enoughHeight = currentBoardSize.height > preservedBoardDimensions.height - 20 // a bit of extra padding
                let shown = shownRaw && enoughWidth && enoughHeight
                return shown
            }

            return false
        }()

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
                        return (400, 300)
                    case .resizingToAddContent:
                        return (420, 120)
                    default:
                        return (.infinity, .infinity)
                    }
                }()

                Color.clear
                    .overlay {
                        ZStack {
                            Circle()
                                .fill(Color.blue.gradient)
                                .blur(radius: 300)
                                .offset(x: animatingBlur ? 200 : -200)

                            Circle()
                                .fill(Color.purple.gradient)
                                .blur(radius: 400)
                                .offset(y: animatingBlur ? 100 : -100)
                        }
                        .aspectRatio(contentMode: .fill)
                        .opacity(0.15)
                        .onAppear {
                            withAnimation(.spring.repeatForever(autoreverses: true)) {
                                animatingBlur = true
                            }
                        }
                    }
                    .drawingGroup()
                    .mask(RoundedRectangle(cornerRadius: 32))
                    .glassBackgroundEffect()
                    .frame(
                        maxWidth: maxWidth,
                        maxHeight: maxHeight
                    )
                    .opacity(shown ? 0 : 1)
                    .animation(shown ? .linear(duration: 1.5) : .spring, value: shown)
            }
            .overlay {
                mainView(shown: shown)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 36)
                    .strokeBorder(Color.blue, lineWidth: 10)
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
                topView(shown: shown)
            }
            .overlay(alignment: .bottomTrailing) {
                bottomRightArrow(shown: shown)
            }
            .overlay {
                ZStack {
                    initialView
                        .opacity(step == .initial ? 1 : 0)

                    stepView
                        .opacity(step == .resizingToFitBoard || step == .resizingToAddContent ? 1 : 0)
                }
                .padding(step == .initial ? 90 : 32)
                .opacity(shown ? 0 : 1)
                .animation(shown ? .linear(duration: 1.5) : .spring, value: shown)
            }
            .animation(.spring, value: step)
            .overlay(alignment: .bottom) {
                bottomOverlay
            }
            .onAppear {
                whisperViewModel.loadModel()
            }
    }

    @ViewBuilder var bottomOverlay: some View {
        VStack {
            if let currentFocusedSegmentID = whisperViewModel.currentFocusedSegmentID {
                HStack(spacing: 32) {
                    Text("History")
                        .bold()

                    if let segment = whisperViewModel.confirmedSegments.first(where: { $0.id == currentFocusedSegmentID }) {
                        HStack {
                            Text("\(String(format: "%.2f", segment.start)) - \(String(format: "%.2f", segment.end))")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        whisperViewModel.currentFocusedSegmentID = nil
                    } label: {
                        Image(systemName: "xmark")
                            .padding()
                    }
                }
                .font(.system(size: 24))
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background {
                    Capsule()
                        .fill(.green.gradient)
                        .brightness(-0.2)
                }
            }
        }
        .animation(.spring, value: whisperViewModel.currentFocusedSegmentID != nil)
        .frame(width: (preservedBoardDimensions?.width ?? 300) - 60)
    }

    var initialView: some View {
        VStack {
            Text("ClassX")
                .font(.system(size: 42, weight: .medium, design: .monospaced))
                .kerning(10)

            Button {
                whisperViewModel.resetState()
                whisperViewModel.confirmedSegments = []
                whisperViewModel.currentText = ""

                step = .resizingToFitBoard

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    allowShowNext = true
                }

            } label: {
                Text("Begin")
                    .font(.system(size: 24, weight: .medium))
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

    func mainView(shown: Bool) -> some View {
        ZStack {
            if let preservedBoardDimensions {
                backgroundSkeletonView(preservedBoardDimensions: preservedBoardDimensions, shown: shown)
                    .opacity(shown ? 0 : 1)

                Color.clear.overlay {
                    augmentedView(preservedBoardDimensions: preservedBoardDimensions, shown: shown)
                }
                .opacity(shown ? 1 : 0)
            }
        }
        .animation(.spring, value: shown)
        .overlay {
            ZStack {
                ForEach(circleAnimations, id: \.self) { _ in
                    Circle()
                        .fill(.green)
                        .blur(radius: 60)
                        .opacity(0.4)
                        .padding(100)
                        .transition(.asymmetric(insertion: .scale(scale: 0.1), removal: .scale(scale: 1.2)).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onChange(of: shown) { newValue in

            if newValue {
                whisperViewModel.start()

                withAnimation {
                    circleAnimations.append(UUID())
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation {
                        circleAnimations = []
                    }
                }
            } else {
                whisperViewModel.end()

                whisperViewModel.currentFocusedSegmentID = nil

                withAnimation {
                    circleAnimations = []
                }
            }
        }
    }

    func backgroundSkeletonView(preservedBoardDimensions: CGSize, shown: Bool) -> some View {
        Color.clear
            .overlay {
                Color.clear
                    .frame(width: preservedBoardDimensions.width, height: preservedBoardDimensions.height)
                    .overlay(align: .leading, to: .trailing) {
                        RoundedRectangle(cornerRadius: 36)
                            .fill(.white)
                            .opacity(0.2)
                            .overlay {
                                RoundedRectangle(cornerRadius: 36)
                                    .strokeBorder(Color.blue, lineWidth: 10)
                            }
                            .frame(width: minimumSideWidth)
                            .offset(x: shown ? 0 : 80)
                    }
                    .overlay(align: .trailing, to: .leading) {
                        RoundedRectangle(cornerRadius: 36)
                            .fill(.white)
                            .opacity(0.2)
                            .overlay {
                                RoundedRectangle(cornerRadius: 36)
                                    .strokeBorder(Color.blue, lineWidth: 10)
                            }
                            .frame(width: minimumSideWidth)
                            .offset(x: shown ? 0 : -80)
                    }
            }
            .mask {
                HStack(spacing: 0) {
                    LinearGradient(colors: [.clear, .white], startPoint: .leading, endPoint: .trailing)
                    Color.white
                        .frame(width: preservedBoardDimensions.width)
                    LinearGradient(colors: [.white, .clear], startPoint: .leading, endPoint: .trailing)
                }
            }
            .opacity(step == .resizingToAddContent ? 1 : 0)
    }

    func augmentedView(preservedBoardDimensions: CGSize, shown: Bool) -> some View {
        HStack {
            Color.clear
                .overlay {
                    switch whisperViewModel.loadingState {
                    case .invalid, .loading:
                        ProgressView()
                            .scaleEffect(2)
                    default:
                        TranscriptView(whisperViewModel: whisperViewModel)
                    }
                }
                .clipped()
                .glassBackgroundEffect()
                .frame(minWidth: minimumSideWidth)

            Color.clear
                .frame(width: preservedBoardDimensions.width)
                .frame(height: preservedBoardDimensions.height)

            Color.clear
                .overlay {
                    switch whisperViewModel.loadingState {
                    case .invalid, .loading:
                        ProgressView()
                            .scaleEffect(2)
                    default:
                        VisualizationsView(whisperViewModel: whisperViewModel)
                    }
                }
                .clipped()
                .glassBackgroundEffect()
                .frame(minWidth: minimumSideWidth)
        }
    }

    func topView(shown: Bool) -> some View {
        HStack(spacing: 24) {
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
                    .font(.system(size: 16, weight: .medium))
            }

            Text(shown ? "ClassX" : "Quick Setup")
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .font(.system(size: 21, weight: .semibold))
                .padding(.vertical, 20)
        }
        .padding(.horizontal, 32)
        .glassBackgroundEffect(displayMode: shown ? .always : .never)
        .frame(maxWidth: .infinity)
        .opacity(step == .resizingToFitBoard || step == .resizingToAddContent ? 1 : 0)
    }

    var stepView: some View {
        VStack(spacing: 48) {
            HStack(spacing: 20) {
                Image(systemName: step == .resizingToAddContent ? "2.circle.fill" : "1.circle.fill")
                    .font(.system(size: 42, weight: .medium))

                VStack(alignment: .leading, spacing: 4) {
                    Text(step == .resizingToAddContent ? "Augment the board!" : "Resize to fit the board!")
                        .font(.system(size: 24, weight: .medium))

                    Text("Drag the bottom-right corner")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 17, weight: .medium))
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
                        .font(.system(size: 21, weight: .medium))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                        .background(
                            Capsule()
                                .fill(.blue.opacity(0.5))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    func bottomRightArrow(shown: Bool) -> some View {
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
                .font(.system(size: 48))
                .frame(width: 80, height: 80)
                .background {
                    ZStack {
                        if shown {
                            Color.green
                        } else {
                            Color.blue
                        }
                    }
                    .opacity(0.3)
                    .brightness(shown ? 0 : 0.5)
                }
                .glassBackgroundEffect(in: Circle())
                .offset(x: step == .resizingToAddContent ? 0 : -300)
                .opacity(step == .resizingToAddContent ? 1 : 0)
                .opacity(shown ? 0 : 1)
                .animation(shown ? .linear(duration: 1.5) : .spring, value: shown)
        }
    }
}
