# Island Watch

Island Watch is an iOS app that helps users track their time spent on social media platforms through an elegant Dynamic Island interface.

## Features

1. **Social Media Hub**: Launch popular social media apps (Instagram, X, YouTube) from a central hub.
2. **Time Tracking**: Automatically track time spent on each social media platform.
3. **Dynamic Island Integration**: View active session timers directly in the Dynamic Island.
4. **Daily Usage Stats**: See total time spent on each platform for the current day.
5. **Auto-Reset**: Daily usage statistics automatically reset at midnight.

## Project Setup

To properly run this project in Xcode, you need to:

1. **Create a Widget Extension Target**:
   - Go to File > New > Target
   - Select "Widget Extension"
   - Name it "IslandWatchWidget"
   - Move the SocialMediaLiveActivityExtension.swift file to this target
   - Add the @main attribute back in this separate target
   
2. **Configure Info.plist entries**:
   - In the main app target's Info tab, add:
     - NSUserActivityTypes (Array): "SocialMediaTimerAttributes"
     - LSApplicationQueriesSchemes (Array): "instagram", "twitter", "youtube"
     - UIApplicationShortcutItems (Array of dictionaries for quick actions)
     - UIBackgroundModes (Array): "remote-notification"
     - NSSupportsLiveActivities (Boolean): YES

3. **Ensure shared code access**:
   - Make sure SocialMediaTimerAttributes.swift is in a location accessible by both targets
   - You may need to set up a framework or use target membership settings

## Technical Implementation

The app leverages several iOS technologies:

- **SwiftUI**: For the modern declarative UI.
- **Live Activities**: To display the active timer in the Dynamic Island.
- **ActivityKit**: To manage Live Activities for the stopwatches.
- **URL Schemes**: To launch social media apps directly.
- **App Shortcuts**: For quick launching social media timers.

## App Structure

- **SocialMediaModel.swift**: Contains the core data model and tracking logic
- **SocialMediaTimerAttributes.swift**: Defines the Live Activity data structure
- **SocialMediaLiveActivityExtension.swift**: Implements Dynamic Island UI
- **ContentView.swift**: Main app UI
- **islandwatchApp.swift**: App entry point and configuration

## Usage

1. Tap on a social media icon to start tracking time for that platform.
2. The app will redirect you to the selected social media app.
3. The Dynamic Island will display the active timer.
4. When you return to Island Watch, the timer pauses automatically.
5. View your daily usage statistics at the bottom of the screen.

## Requirements

- iOS 16.1 or later (for Dynamic Island support)
- iPhone with Dynamic Island (iPhone 14 Pro and newer)

## Privacy

Island Watch operates entirely on-device. No usage data is uploaded to any server - all tracking is local to your device and resets daily. 