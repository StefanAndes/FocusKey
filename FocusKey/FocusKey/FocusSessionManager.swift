//
//  FocusSessionManager.swift
//  FocusKey
//
//  Created by Stefan Andelkovic on 2025-01-05.
//

import Foundation
import SwiftUI
import SwiftData
#if os(iOS)
import FamilyControls
import ManagedSettings
import DeviceActivity
#endif

@MainActor
class FocusSessionManager: ObservableObject {
    
    static let shared = FocusSessionManager()
    
    @Published var isSessionActive = false
    @Published var currentProfile: FocusProfile?
    @Published var sessionStartTime: Date?
    @Published var isOnBreak = false
    @Published var breakStartTime: Date?
    @Published var breaksUsed = 0
    
    #if os(iOS)
    private let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("FocusKeyRestrictions"))
    private let activityCenter = DeviceActivityCenter()
    private let activityName = DeviceActivityName("FocusKeyActiveSession")
    #endif
    
    // SwiftData context for session tracking
    private var modelContext: ModelContext?
    private var currentSessionHistory: SessionHistory?
    
    private init() {}
    
    // Set the model context from the app
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Authorization Check
    
    var isAuthorized: Bool {
        #if os(iOS)
        return AuthorizationCenter.shared.authorizationStatus == .approved
        #else
        return false
        #endif
    }
    
    // MARK: - Session Management
    
    func startFocusSession(with profile: FocusProfile, triggerMethod: String = "manual") async throws {
        guard isAuthorized else {
            throw FocusSessionError.notAuthorized
        }
        
        guard !isSessionActive else {
            throw FocusSessionError.sessionAlreadyActive
        }
        
        #if os(iOS)
        // Configure the managed settings store with the profile's app selection
        store.shield.applications = profile.activitySelection.applicationTokens.isEmpty ? 
            nil : profile.activitySelection.applicationTokens
        
        store.shield.applicationCategories = profile.activitySelection.categoryTokens.isEmpty ? 
            nil : .specific(profile.activitySelection.categoryTokens)
        
        store.shield.webDomains = profile.activitySelection.webDomainTokens.isEmpty ? 
            nil : profile.activitySelection.webDomainTokens
        
        // Create an "always on" schedule for immediate session
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        // Start monitoring
        try activityCenter.startMonitoring(activityName, during: schedule)
        #endif
        
        // Update session state
        currentProfile = profile
        sessionStartTime = Date()
        isSessionActive = true
        breaksUsed = 0
        
        // Create session history record
        createSessionHistory(profile: profile, triggerMethod: triggerMethod)
        
        print("✅ Focus session started with profile: \(profile.name)")
    }
    
    func endFocusSession() async throws {
        guard isSessionActive else {
            throw FocusSessionError.noActiveSession
        }
        
        #if os(iOS)
        // Stop monitoring
        activityCenter.stopMonitoring([activityName])
        
        // Clear the shield
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        #endif
        
        // Log the session
        if let profile = currentProfile, let startTime = sessionStartTime {
            logCompletedSession(profile: profile, startTime: startTime, endTime: Date(), naturally: true)
        }
        
        // Reset session state
        currentProfile = nil
        sessionStartTime = nil
        isSessionActive = false
        isOnBreak = false
        breakStartTime = nil
        breaksUsed = 0
        
        print("✅ Focus session ended")
    }
    
    // MARK: - Break Management
    
    func canTakeBreak() -> Bool {
        guard let profile = currentProfile else { return false }
        return isSessionActive && !isOnBreak && breaksUsed < profile.allowedBreaks
    }
    
    func startBreak() async throws {
        guard canTakeBreak() else {
            throw FocusSessionError.noBreaksAvailable
        }
        
        #if os(iOS)
        // Temporarily stop monitoring to allow app access
        activityCenter.stopMonitoring([activityName])
        
        // Clear the shield temporarily
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        #endif
        
        isOnBreak = true
        breakStartTime = Date()
        breaksUsed += 1
        
        // Log break in session history
        logBreakTaken()
        
        // Schedule automatic resume
        if let profile = currentProfile {
            scheduleBreakEnd(duration: profile.breakDuration)
        }
        
        print("☕ Break started (\(breaksUsed)/\(currentProfile?.allowedBreaks ?? 0))")
    }
    
    func endBreak() async throws {
        guard isOnBreak else {
            throw FocusSessionError.notOnBreak
        }
        
        guard let profile = currentProfile else {
            throw FocusSessionError.noActiveSession
        }
        
        #if os(iOS)
        // Reapply the restrictions
        store.shield.applications = profile.activitySelection.applicationTokens.isEmpty ? 
            nil : profile.activitySelection.applicationTokens
        
        store.shield.applicationCategories = profile.activitySelection.categoryTokens.isEmpty ? 
            nil : .specific(profile.activitySelection.categoryTokens)
        
        store.shield.webDomains = profile.activitySelection.webDomainTokens.isEmpty ? 
            nil : profile.activitySelection.webDomainTokens
        
        // Resume monitoring
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        try activityCenter.startMonitoring(activityName, during: schedule)
        #endif
        
        isOnBreak = false
        breakStartTime = nil
        
        print("🔒 Break ended, focus resumed")
    }
    
    private func scheduleBreakEnd(duration: Int) {
        Task {
            try await Task.sleep(nanoseconds: UInt64(duration * 60 * 1_000_000_000)) // minutes to nanoseconds
            
            if isOnBreak {
                try await endBreak()
            }
        }
    }
    
    // MARK: - Session Logging
    
    private func logCompletedSession(profile: FocusProfile, startTime: Date, endTime: Date, naturally: Bool) {
        let duration = endTime.timeIntervalSince(startTime)
        
        // Update and save the session history
        if let sessionHistory = currentSessionHistory, let context = modelContext {
            sessionHistory.endSession(naturally: naturally)
            sessionHistory.updateFocusTime()
            
            do {
                try context.save()
                print("📊 Session saved to history: \(profile.name) - \(Int(duration/60)) minutes, \(breaksUsed) breaks")
            } catch {
                print("❌ Failed to save session history: \(error)")
            }
        } else {
            print("📊 Session logged (not saved): \(profile.name) - \(Int(duration/60)) minutes, \(breaksUsed) breaks")
        }
        
        // Clear current session reference
        currentSessionHistory = nil
    }
    
    private func createSessionHistory(profile: FocusProfile, triggerMethod: String) {
        guard let context = modelContext else {
            print("⚠️ No model context available for session tracking")
            return
        }
        
        let sessionHistory = SessionHistory(profileName: profile.name, triggerMethod: triggerMethod)
        context.insert(sessionHistory)
        
        self.currentSessionHistory = sessionHistory
        
        do {
            try context.save()
            print("📝 Session history created for \(profile.name)")
        } catch {
            print("❌ Failed to create session history: \(error)")
        }
    }
    
    private func logBreakTaken() {
        guard let sessionHistory = currentSessionHistory,
              let profile = currentProfile else { return }
        
        sessionHistory.addBreak(duration: TimeInterval(profile.breakDuration * 60))
        
        if let context = modelContext {
            do {
                try context.save()
                print("☕ Break logged in session history")
            } catch {
                print("❌ Failed to log break: \(error)")
            }
        }
    }
    
    // MARK: - Session Info
    
    var sessionDuration: TimeInterval? {
        guard let startTime = sessionStartTime else { return nil }
        return Date().timeIntervalSince(startTime)
    }
    
    var breakTimeRemaining: TimeInterval? {
        guard let breakStart = breakStartTime,
              let profile = currentProfile else { return nil }
        
        let elapsed = Date().timeIntervalSince(breakStart)
        let total = TimeInterval(profile.breakDuration * 60)
        return max(0, total - elapsed)
    }
}

// MARK: - Error Types

enum FocusSessionError: LocalizedError {
    case notAuthorized
    case sessionAlreadyActive
    case noActiveSession
    case noBreaksAvailable
    case notOnBreak
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Screen Time authorization is required"
        case .sessionAlreadyActive:
            return "A focus session is already active"
        case .noActiveSession:
            return "No active focus session"
        case .noBreaksAvailable:
            return "No breaks remaining for this session"
        case .notOnBreak:
            return "Not currently on a break"
        }
    }
} 