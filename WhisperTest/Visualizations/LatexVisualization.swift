//
//  LatexVisualization.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/17/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftMath
import SwiftUI

struct LatexVisualization: View {
    var body: some View {
        let parts = LatexModel.getParts(inputText: TestingData.latex)
        
        VStack(alignment: .leading) {
            ForEach(parts) { part in
                switch part.content {
                case .latex(let text):
                    MathView(equation: text, fontSize: 17)
                case .normal(let text):
                    Text(.init(text))
                }
            }
        }
    }
}

struct MathView: UIViewRepresentable {
    var equation: String
    var fontSize: CGFloat
    
    func makeUIView(context: Context) -> MTMathUILabel {
        let view = MTMathUILabel()
        return view
    }
    
    func updateUIView(_ uiView: MTMathUILabel, context: Context) {
        uiView.latex = equation
        uiView.fontSize = fontSize
        uiView.font = MTFontManager().termesFont(withSize: fontSize)
        uiView.textAlignment = .left
        uiView.labelMode = .text
    }
}

enum LatexModel {
    struct Part: Identifiable {
        var id = UUID().uuidString
        var content: Content
        
        enum Content {
            case latex(String)
            case normal(String)
        }
    }

    // Regular expression to find LaTeX parts
    static let latexPattern = "(\\$.*?\\$)|\\\\begin\\{.*?\\}(.*?)\\\\end\\{.*?\\}"
    static let regex = try! NSRegularExpression(pattern: latexPattern, options: [.dotMatchesLineSeparators])

    static func getParts(inputText: String) -> [Part] {
        // Results array
        var parts: [Part] = []
        
        // Initial non-LaTeX part index
        var lastEndIndex = inputText.startIndex
        
        // Iterate through matches
        let matches = regex.matches(in: inputText, options: [], range: NSRange(inputText.startIndex..., in: inputText))
        for match in matches {
            // Extract non-LaTeX part
            let nonLatexRange = Range(uncheckedBounds: (lower: lastEndIndex, upper: Range(match.range, in: inputText)!.lowerBound))
            if !inputText[nonLatexRange].isEmpty {
                parts.append(.init(content: .normal(String(inputText[nonLatexRange]))))
            }
            
            // Extract LaTeX part
            if let range = Range(match.range, in: inputText) {
                parts.append(.init(content: .latex(String(inputText[range]))))
            }
            
            // Update last end index
            lastEndIndex = Range(match.range, in: inputText)!.upperBound
        }
        
        // Add remaining non-LaTeX part if any
        if lastEndIndex < inputText.endIndex {
            parts.append(.init(content: .normal(String(inputText[lastEndIndex...]))))
        }
        
        return parts
    }
}
