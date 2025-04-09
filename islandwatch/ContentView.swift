//
//  ContentView.swift
//  islandwatch
//
//  Created by Akylbek Khamitov on 4/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var tracker: SocialMediaTracker
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            
            activePlatformView
            
            Spacer()
            
            platformsGridView
            
            Spacer()
            
            dailySummaryView
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // When app comes to foreground, pause the current session
            tracker.pauseSession()
        }
        .onAppear {
            // Connect the tracker to the app delegate so shortcuts can access it
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.tracker = tracker
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Island Watch")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            if tracker.activePlatform != nil {
                Button(action: {
                    tracker.endCurrentSession()
                }) {
                    Text("Reset")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var activePlatformView: some View {
        Group {
            if let platform = tracker.activePlatform {
                VStack(spacing: 12) {
                    Text("Current Platform: \(platform.name)")
                        .font(.headline)
                    
                    Text(tracker.formattedTime())
                        .font(.system(size: 54, weight: .bold, design: .monospaced))
                        .foregroundColor(platform.color)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            if tracker.isRunning {
                                tracker.pauseSession()
                            } else {
                                tracker.resumeSession()
                            }
                        }) {
                            Text(tracker.isRunning ? "Pause" : "Resume")
                                .font(.headline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(platform.color)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            tracker.endCurrentSession()
                        }) {
                            Text("Stop")
                                .font(.headline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
            } else {
                Text("Tap a platform below to start tracking")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
            }
        }
    }
    
    private var platformsGridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            ForEach(SocialPlatform.allCases) { platform in
                Button(action: {
                    tracker.startSession(for: platform)
                }) {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(platform.color.opacity(0.2))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: getPlatformIconName(platform))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
                                .foregroundColor(platform.color)
                        }
                        
                        Text(platform.name)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var dailySummaryView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today's Usage")
                .font(.headline)
            
            ForEach(SocialPlatform.allCases) { platform in
                HStack {
                    Image(systemName: getPlatformIconName(platform))
                        .foregroundColor(platform.color)
                        .frame(width: 24)
                    
                    Text(platform.name)
                    
                    Spacer()
                    
                    Text(tracker.formattedTime(for: platform))
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // Helper function to get platform-specific icon names
    private func getPlatformIconName(_ platform: SocialPlatform) -> String {
        switch platform {
        case .instagram: return "square.and.arrow.up"
        case .twitter: return "bird"
        case .youtube: return "play.rectangle"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SocialMediaTracker())
}
