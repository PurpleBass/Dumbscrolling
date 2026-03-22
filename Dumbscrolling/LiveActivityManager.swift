import ActivityKit
import Foundation

@MainActor
class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var activity: Activity<ShameActivityAttributes>?

    func start() async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = ShameActivityAttributes(sessionStartDate: Date())
        let state = ShameActivityAttributes.ContentState(
            elapsedSeconds: 0,
            shameMessage: "YOU'RE DOOMSCROLLING   ★   "
        )
        let content = ActivityContent(state: state, staleDate: nil)
        activity = try? Activity.request(attributes: attributes, content: content, pushType: nil)
    }

    func update(elapsed: Int, message: String) async {
        let state = ShameActivityAttributes.ContentState(elapsedSeconds: elapsed, shameMessage: message)
        let content = ActivityContent(state: state, staleDate: nil)
        await activity?.update(content)
    }

    func end() async {
        let state = ShameActivityAttributes.ContentState(elapsedSeconds: 0, shameMessage: "SHAME SESSION OVER   ★   ")
        let content = ActivityContent(state: state, staleDate: nil)
        await activity?.end(content, dismissalPolicy: .immediate)
        activity = nil
    }
}
