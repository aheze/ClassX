//
//  WhisperVM+Listen.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/18/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

extension WhisperViewModel {
    func listen() {
        // upload
        reactToSegmentsChange()
    }
    
    func reactToSegmentsChange() {
        $confirmedSegments
            .dropFirst()
            .throttle(for: .seconds(8), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] confirmedSegments in
                guard let self else { return }

                if let testingConfiguration = self.testingConfiguration, testingConfiguration.useSnapshotsForVisualizations {
                    return
                }
                
                
                let confirmedSegments = confirmedSegments.suffix(10)
                guard let last = confirmedSegments.last else { return }
                
                let segments = confirmedSegments.map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
                
                let upload = WhisperUpload(id: last.id, uploadNumber: self.currentUploadNumber, segments: segments)
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted

                do {
                    let data = try encoder.encode(upload)
                    self.upload(data: data)
                    
                    guard let string = String(data: data, encoding: .utf8) else {
                        print("Couldn't make string from data")
                        return
                    }
                    
                    self.currentUploadNumber += 1
                    
                    print("Received data!!!!")
                    print(string)
                    
                } catch {
                    print("Error encoding: \(error)")
                }
            }
            .store(in: &cancellables)
    }
    
    func upload(data: Data) {
        // Define the URL object
        if let url = URL(string: "https://7eb4-68-65-169-179.ngrok-free.app/search") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data

            // Create a URLSession data task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "No error description")")
                    return
                }

                // Handle the response here
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    // Check for http errors
                    print("StatusCode should be 200, but is \(httpStatus.statusCode)")
                    print("Response = \(response!)")
                }

                // Try to parse the JSON data
                do {
//                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        print("Response JSON: \(jsonResponse)")
//                    }
                    
                    let decoder = JSONDecoder()
                    
                    let serverResponse = try decoder.decode(ServerResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.serverResponseBySegmentID[serverResponse.id] = serverResponse
                        
                        if let currentFocusedSegmentID = self.currentFocusedSegmentID {
                        } else {
                            let isLatest = self.confirmedSegments.last?.id == serverResponse.id
                            print("isLatest? \(isLatest)")
                            if isLatest {
                                self.displayVisualizations(visualizations: serverResponse.visualizations)
                            }
                        }
                    }
                    
                    print("serverResponse: \(serverResponse)")
                } catch {
                    print("Failed to parse JSON:", error)
                }
            }

            // Start the task
            task.resume()
        }
    }
}
