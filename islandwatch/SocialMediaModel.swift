import Foundation
import ActivityKit
import SwiftUI

enum SocialPlatform: String, CaseIterable, Identifiable {
    case instagram
    case twitter // X
    case youtube
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .instagram: return "Instagram"
        case .twitter: return "X"
        case .youtube: return "YouTube"
        }
    }
    
    var icon: String {
        switch self {
        case .instagram: return "instagram.logo"
        case .twitter: return "twitter.logo" 
        case .youtube: return "youtube.logo"
        }
    }
    
    var urlScheme: URL? {
        switch self {
        case .instagram: return URL(string: "instagram://")
        case .twitter: return URL(string: "twitter://")
        case .youtube: return URL(string: "youtube://")
        }
    }
    
    var color: Color {
        switch self {
        case .instagram: return Color(red: 0.91, green: 0.27, blue: 0.54)
        case .twitter: return Color.black
        case .youtube: return Color.red
        }
    }
}

class SocialMediaTracker: ObservableObject {
    @Published var activePlatform: SocialPlatform?
    @Published var isRunning = false
    @Published var startTime: Date?
    @Published var elapsedTime: TimeInterval = 0
    @Published var platformUsageTimes: [SocialPlatform: TimeInterval] = [:]
    @Published var lastRedirectError: String? = nil
    
    private var liveActivity: Activity<SocialMediaTimerAttributes>?
    private var timer: Timer?
    
    init() {
        // Initialize usage times for all platforms
        for platform in SocialPlatform.allCases {
            platformUsageTimes[platform] = loadDailyUsageTime(for: platform)
        }
        
        // Check if we need to reset daily times
        checkAndResetDailyTimes()
        
        // Schedule daily reset at midnight
        scheduleDailyReset()
    }
    
    func startSession(for platform: SocialPlatform) {
        activePlatform = platform
        isRunning = true
        startTime = Date()
        
        // Start timer for UI updates
        startTimer()
        
        // Start live activity
        startLiveActivity(for: platform)
        
        // Open the app using URL scheme with error handling
        openSocialApp(platform) { success in
            if !success {
                print("Failed to open \(platform.name) app. Make sure it's installed.")
            }
        }
    }
    
    func pauseSession() {
        guard isRunning, let platform = activePlatform, let start = startTime else { return }
        
        isRunning = false
        let sessionDuration = Date().timeIntervalSince(start)
        elapsedTime += sessionDuration
        startTime = nil
        
        // Update accumulated time for the platform
        platformUsageTimes[platform] = (platformUsageTimes[platform] ?? 0) + sessionDuration
        
        // Save to UserDefaults
        saveDailyUsageTime(for: platform)
        
        // Stop timer
        stopTimer()
        
        // Update live activity
        updateLiveActivity()
    }
    
    func resumeSession() {
        guard !isRunning, let platform = activePlatform else { return }
        
        isRunning = true
        startTime = Date()
        
        // Restart timer
        startTimer()
        
        // Update live activity
        updateLiveActivity()
        
        // Open the app using URL scheme with error handling
        openSocialApp(platform) { success in
            if !success {
                print("Failed to resume \(platform.name) app. Make sure it's installed.")
            }
        }
    }
    
    private func startTimer() {
        // Use a more frequent timer (10 updates per second) for smoother UI
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isRunning, let startTime = self.startTime else { return }
            let current = self.elapsedTime + Date().timeIntervalSince(startTime)
            
            // Update live activity less frequently (once per second) to reduce system load
            if Int(current * 10) % 10 == 0 {
                self.updateLiveActivity(with: current)
            }
        }
        
        // Make sure the timer continues to fire when scrolling
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startLiveActivity(for platform: SocialPlatform) {
        let attributes = SocialMediaTimerAttributes(platformName: platform.name)
        let initialState = SocialMediaTimerAttributes.ContentState(elapsedTime: elapsedTime)
        
        do {
            liveActivity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
        } catch {
            print("Error starting live activity: \(error.localizedDescription)")
        }
    }
    
    private func updateLiveActivity(with currentTime: TimeInterval? = nil) {
        guard let liveActivity = liveActivity else { return }
        
        let time = currentTime ?? elapsedTime
        
        Task {
            await liveActivity.update(
                using: SocialMediaTimerAttributes.ContentState(elapsedTime: time)
            )
            
            // If session is ended completely, end the activity
            if !isRunning && activePlatform == nil {
                await liveActivity.end(
                    using: SocialMediaTimerAttributes.ContentState(elapsedTime: time),
                    dismissalPolicy: .immediate
                )
                self.liveActivity = nil
            }
        }
    }
    
    func endCurrentSession() {
        pauseSession()
        activePlatform = nil
        elapsedTime = 0
        
        // End live activity
        if let liveActivity = liveActivity {
            Task {
                await liveActivity.end(
                    using: SocialMediaTimerAttributes.ContentState(elapsedTime: 0),
                    dismissalPolicy: .immediate
                )
                self.liveActivity = nil
            }
        }
    }
    
    // MARK: - Persistence
    
    private func userDefaultsKey(for platform: SocialPlatform) -> String {
        return "dailyUsage_\(platform.rawValue)"
    }
    
    private func lastResetDateKey() -> String {
        return "lastResetDate"
    }
    
    private func saveDailyUsageTime(for platform: SocialPlatform) {
        let key = userDefaultsKey(for: platform)
        UserDefaults.standard.set(platformUsageTimes[platform], forKey: key)
    }
    
    private func loadDailyUsageTime(for platform: SocialPlatform) -> TimeInterval {
        let key = userDefaultsKey(for: platform)
        return UserDefaults.standard.double(forKey: key)
    }
    
    private func checkAndResetDailyTimes() {
        let calendar = Calendar.current
        let now = Date()
        
        if let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey()) as? Date {
            // Check if we're in a new day compared to the last reset
            if !calendar.isDate(lastResetDate, inSameDayAs: now) {
                resetAllDailyTimes()
            }
        } else {
            // First time app runs, save current date
            UserDefaults.standard.set(now, forKey: lastResetDateKey())
        }
    }
    
    private func resetAllDailyTimes() {
        for platform in SocialPlatform.allCases {
            platformUsageTimes[platform] = 0
            saveDailyUsageTime(for: platform)
        }
        
        // Update last reset date
        UserDefaults.standard.set(Date(), forKey: lastResetDateKey())
    }
    
    private func scheduleDailyReset() {
        // Set up a notification to reset counters at midnight
        let calendar = Calendar.current
        
        // Get the start of tomorrow
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
              let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) else {
            return
        }
        
        // Calculate seconds until midnight
        let timeUntilMidnight = midnight.timeIntervalSince(Date())
        
        // Schedule a timer to reset at midnight
        Timer.scheduledTimer(withTimeInterval: timeUntilMidnight, repeats: false) { [weak self] _ in
            self?.resetAllDailyTimes()
            // Schedule the next day's reset
            self?.scheduleDailyReset()
        }
    }
    
    // Helper to format time nicely for display
    func formattedTime(for platform: SocialPlatform? = nil) -> String {
        let time: TimeInterval
        
        if let platform = platform {
            time = platformUsageTimes[platform] ?? 0
        } else if isRunning, let startTime = startTime {
            time = elapsedTime + Date().timeIntervalSince(startTime)
        } else {
            time = elapsedTime
        }
        
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func openSocialApp(_ platform: SocialPlatform, completion: @escaping (Bool) -> Void) {
        // Reset any previous error
        lastRedirectError = nil
        
        guard let url = platform.urlScheme else {
            lastRedirectError = "Invalid URL scheme for \(platform.name)"
            completion(false)
            return
        }
        
        // Check if app is installed
        if UIApplication.shared.canOpenURL(url) {
            // Use newer API with completion handler for better reliability
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    self.lastRedirectError = "Could not open \(platform.name). Please check if the app is installed."
                }
                completion(success)
            }
        } else {
            // If app is not installed, try to open web version instead
            let webURL: URL?
            switch platform {
            case .instagram: webURL = URL(string: "https://www.instagram.com")
            case .twitter: webURL = URL(string: "https://x.com")
            case .youtube: webURL = URL(string: "https://www.youtube.com")
            }
            
            if let webURL = webURL {
                self.lastRedirectError = "\(platform.name) app not found. Opening web version instead."
                UIApplication.shared.open(webURL, options: [:], completionHandler: completion)
            } else {
                self.lastRedirectError = "Could not open \(platform.name). Please make sure the app is installed."
                completion(false)
            }
        }
    }
} 