import ActivityKit
import Foundation

struct ShameActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var shameMessage: String
    }

    var sessionStartDate: Date
}
