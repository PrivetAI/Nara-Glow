import SwiftUI
import WebKit

struct SporeWebPanel: UIViewRepresentable {
    let urlString: String
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.isOpaque = true
        webView.backgroundColor = UIColor(red: 0.055, green: 0.075, blue: 0.070, alpha: 1.0)
        if let url = URL(string: urlString) { webView.load(URLRequest(url: url)) }
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
