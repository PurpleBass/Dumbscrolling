import Foundation
import Combine

class ShameSession: ObservableObject {
    @Published var isActive = false
    @Published var elapsedSeconds = 0
    @Published var currentShameMessage = ShameSession.shameMessages[0]

    private var timer: AnyCancellable?
    private var messageTimer: AnyCancellable?

    static let shameMessages: [String] = [
        "YOUR FUTURE SELF IS DISAPPOINTED   ★   ",
        "PUT THE PHONE DOWN   ★   ",
        "THAT REEL WON'T CHANGE YOUR LIFE   ★   ",
        "YOUR GOALS ARE WAITING   ★   ",
        "YOU'VE BEEN SCROLLING FOR \(0) MINUTES   ★   ",
        "TOUCH GRASS   ★   ",
        "NOBODY CARES ABOUT THAT POST   ★   ",
        "GO DRINK SOME WATER   ★   ",
        "YOUR DREAMS DON'T SCROLL THEMSELVES   ★   ",
        "CLOSE THE APP. NOW.   ★   ",
    ]

    func shameMessage(for seconds: Int) -> String {
        let minutes = seconds / 60
        let msgs: [String] = [
            "YOU'VE BEEN DOOMSCROLLING \(minutes)m \(seconds % 60)s   ★   ",
            "PUT THE PHONE DOWN   ★   ",
            "TOUCH GRASS   ★   ",
            "YOUR FUTURE SELF IS CRINGING   ★   ",
            "GO DO LITERALLY ANYTHING ELSE   ★   ",
            "YOUR GOALS ARE WAITING   ★   ",
            "CLOSE THE APP. NOW.   ★   ",
            "THAT REEL WON'T CHANGE YOUR LIFE   ★   ",
            "NOBODY ASKED   ★   ",
            "BRAIN ROT IN PROGRESS   ★   ",
        ]
        return msgs[(seconds / 15) % msgs.count]
    }

    func start() {
        isActive = true
        elapsedSeconds = 0
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.elapsedSeconds += 1
                self.currentShameMessage = self.shameMessage(for: self.elapsedSeconds)
                Task { await LiveActivityManager.shared.update(elapsed: self.elapsedSeconds, message: self.currentShameMessage) }
            }
    }

    func stop() {
        isActive = false
        timer?.cancel()
        timer = nil
        Task { await LiveActivityManager.shared.end() }
    }

    var formattedTime: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
