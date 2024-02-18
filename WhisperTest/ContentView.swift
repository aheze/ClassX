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
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Hello, world!")
            
            switch whisperViewModel.loadingState {
            case .invalid:
                Text("About to load")
            case .loading:
                ProgressView()
            case .done:
                Button(whisperViewModel.isRecording ? "Stop" : "Record") {
                    whisperViewModel.toggle()
                }
            }
            
            Divider()
            
            TranscriptView(whisperViewModel: whisperViewModel)
                .frame(maxHeight: 500)
                .padding()
        }
        .padding()
        .onAppear {
            whisperViewModel.loadModel()
        }
    }
}

#Preview {
    ContentView()
}
