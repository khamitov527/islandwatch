import ActivityKit
import SwiftUI

struct SocialMediaTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedTime: TimeInterval
    }
    
    var platformName: String
} 