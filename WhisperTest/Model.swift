//
//  Model.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/17/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct WhisperUpload: Codable {
    var id: String = UUID().uuidString
    
    // every time I upload, this is incremented
    var uploadNumber: Int
    
    // all segments. Each upload, focus on the newest segments. Is there enough change to warrant a new set of visualizations?
    var segments: [String]
}

enum VisualizationType: Codable {
    case latex
    case url
    case image
    case plainText
}

struct Visualization: Codable {
    // a unique identifier. No two visualizations should have the same ID.
    var id: String
    
    var visualizationType: VisualizationType
    
    // for latex: the latex
    // for url: the url
    // for image: the url of the image
    // for plainText: just the text to show
    var mainBody: String?
    
    // e.g. 3b1b
    var sourceTitle: String?
}

struct ServerResponse: Codable {
    // should match the ID of the WhisperUpload
    var id: String
    
    var uploadNumber: Int
    
    var visualizations: [Visualization]
}
