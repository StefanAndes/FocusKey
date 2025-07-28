//
//  FocusKeyApp.swift
//  FocusKey
//
//  Created by Stefan Andelkovic on 2025-07-28.
//

import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

@main
struct FocusKeyApp: App {
    @StateObject private var sessionManager = FocusSessionManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
                .onOpenURL { url in
                    handleUniversalLink(url)
                }
        }
    }
    
    private func handleUniversalLink(_ url: URL) {
        print("🔗 Universal Link received: \(url)")
        
        guard url.host == "focuskey.app" else {
            print("❌ Invalid host: \(url.host ?? "nil")")
            return
        }
        
        Task { @MainActor in
            await processNFCTrigger(from: url)
        }
    }
    
    @MainActor
    private func processNFCTrigger(from url: URL) async {
        let path = url.path
        
        switch path {
        case "/start":
            await handleStartTrigger()
        case "/toggle":
            await handleToggleTrigger()
        case "/break":
            await handleBreakTrigger()
        default:
            print("🤷‍♂️ Unknown NFC action: \(path)")
        }
    }
    
    @MainActor
    private func handleStartTrigger() async {
        if sessionManager.isSessionActive {
            // If session active, show confirmation dialog instead of immediate stop
            print("📱 Session active - would show confirmation dialog")
            // TODO: Present confirmation dialog
        } else {
            // Start session with default or last used profile
            await startWithDefaultProfile()
        }
    }
    
    @MainActor
    private func handleToggleTrigger() async {
        if sessionManager.isSessionActive {
            // End current session
            do {
                try await sessionManager.endFocusSession()
                print("🔴 Session ended via NFC")
            } catch {
                print("❌ Error ending session: \(error)")
            }
        } else {
            // Start new session
            await startWithDefaultProfile()
        }
    }
    
    @MainActor
    private func handleBreakTrigger() async {
        if sessionManager.isSessionActive && !sessionManager.isOnBreak {
            if sessionManager.canTakeBreak() {
                do {
                    try await sessionManager.startBreak()
                    print("☕ Break started via NFC")
                } catch {
                    print("❌ Error starting break: \(error)")
                }
            } else {
                print("🚫 No breaks available")
            }
        }
    }
    
    @MainActor
    private func startWithDefaultProfile() async {
        // Use Work profile as default, or first available profile
        let defaultProfile = FocusProfile.defaultProfiles.first { $0.name == "Work" } 
                           ?? FocusProfile.defaultProfiles.first
        
        guard let profile = defaultProfile else {
            print("❌ No profiles available")
            return
        }
        
        do {
            try await sessionManager.startFocusSession(with: profile)
            print("🚀 Session started with \(profile.name) profile via NFC")
        } catch {
            print("❌ Error starting session: \(error)")
        }
    }
}
