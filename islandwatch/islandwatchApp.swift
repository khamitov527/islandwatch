//
//  islandwatchApp.swift
//  islandwatch
//
//  Created by Akylbek Khamitov on 4/9/25.
//

import SwiftUI
import ActivityKit

@main
struct islandwatchApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var tracker = SocialMediaTracker()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tracker)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var tracker: SocialMediaTracker?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Request permission for notifications if needed for Live Activities
        requestNotificationPermissions()
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Handle shortcut item if app is launched via quick action
        if let shortcutItem = options.shortcutItem {
            handleShortcutItem(shortcutItem)
        }
        
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        // This will be called when the app is cold-launched via a shortcut
        let type = shortcutItem.type
        
        switch type {
        case "com.islandwatch.startInstagram":
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.tracker?.startSession(for: .instagram)
            }
        case "com.islandwatch.startTwitter":
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.tracker?.startSession(for: .twitter)
            }
        case "com.islandwatch.startYouTube":
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.tracker?.startSession(for: .youtube)
            }
        default:
            break
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
        }
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var tracker: SocialMediaTracker?
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // This is called when the app is already running and the user taps a shortcut
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.handleShortcutItem(shortcutItem)
        completionHandler(true)
    }
}
