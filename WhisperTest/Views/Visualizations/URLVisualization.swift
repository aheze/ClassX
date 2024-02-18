//
//  URLVisualization.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/18/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI
import WebKit

struct URLVisualization: View {
    var urlString: String

    var body: some View {
        if let url = URL(string: urlString) {
            WebView(url: url)
        } else {
            Text("URL parsing error")
                .foregroundStyle(.red)
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // This space can be left blank
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("Webview started loading.")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Webview finished loading.")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Webview failed with error: \(error.localizedDescription)")
        }
    }
}
