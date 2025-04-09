import SwiftUI
import ActivityKit
import WidgetKit

struct SocialMediaWidgetExtension: WidgetBundle {
    var body: some Widget {
        SocialMediaLiveActivityWidget()
    }
}

struct SocialMediaLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SocialMediaTimerAttributes.self) { context in
            SocialMediaLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.platformName, systemImage: "timer")
                        .font(.headline)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formattedTime(timeInterval: context.state.elapsedTime))
                        .font(.headline)
                        .monospacedDigit()
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text("Tracking...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    SocialMediaLiveActivityExpandedView(context: context)
                }
            } compactLeading: {
                Label {
                    Text(context.attributes.platformName)
                } icon: {
                    Image(systemName: "timer")
                }
                .font(.caption2)
            } compactTrailing: {
                Text(formattedTime(timeInterval: context.state.elapsedTime))
                    .monospacedDigit()
                    .font(.caption2)
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
    
    private func formattedTime(timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct SocialMediaLiveActivityView: View {
    let context: ActivityViewContext<SocialMediaTimerAttributes>
    
    var body: some View {
        HStack {
            Text(context.attributes.platformName)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text(formattedTime(timeInterval: context.state.elapsedTime))
                .monospacedDigit()
                .fontWeight(.bold)
        }
        .padding(.horizontal)
    }
    
    private func formattedTime(timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct SocialMediaLiveActivityExpandedView: View {
    let context: ActivityViewContext<SocialMediaTimerAttributes>
    
    var body: some View {
        VStack {
            HStack {
                Text(context.attributes.platformName)
                    .font(.headline)
                
                Spacer()
                
                Text("Active Session")
                    .font(.subheadline)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Session Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formattedTime(timeInterval: context.state.elapsedTime))
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                }
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Text("Tap to pause")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
    }
    
    private func formattedTime(timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
} 