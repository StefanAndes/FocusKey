//
//  ContentView.swift
//  FocusKey
//
//  Created by Stefan Andelkovic on 2025-07-28.
//

import SwiftUI
import SwiftData
#if os(iOS)
import FamilyControls
import UIKit
#endif

struct ContentView: View {
    #if os(iOS)
    @State private var authorizationStatus: AuthorizationStatus = .notDetermined
    #endif
    @State private var isRequestingAuth = false
    @State private var showingAuthError = false
    
    var body: some View {
        NavigationView {
            Group {
                #if os(iOS)
                switch authorizationStatus {
                case .notDetermined:
                    OnboardingView(
                        onRequestAuth: requestAuthorization,
                        isRequesting: isRequestingAuth
                    )
                case .approved:
                    MainAppView()
                case .denied:
                    AuthorizationDeniedView()
                @unknown default:
                    OnboardingView(
                        onRequestAuth: requestAuthorization,
                        isRequesting: isRequestingAuth
                    )
                }
                #else
                VStack {
                    Text("FocusKey")
                        .font(.largeTitle)
                    Text("This app requires iOS")
                        .foregroundColor(.secondary)
                }
                #endif
            }
            .alert("Authorization Failed", isPresented: $showingAuthError) {
                Button("OK") { }
            } message: {
                Text("Failed to request Screen Time authorization. Please try again.")
            }
        }
        .onAppear {
            checkAuthorizationStatus()
        }
    }
    
    private func checkAuthorizationStatus() {
        #if os(iOS)
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        #endif
    }
    
    private func requestAuthorization() {
        #if os(iOS)
        guard !isRequestingAuth else { return }
        isRequestingAuth = true
        
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                await MainActor.run {
                    authorizationStatus = AuthorizationCenter.shared.authorizationStatus
                    isRequestingAuth = false
                }
            } catch {
                await MainActor.run {
                    isRequestingAuth = false
                    showingAuthError = true
                }
            }
        }
        #endif
    }
}

struct OnboardingView: View {
    let onRequestAuth: () -> Void
    let isRequesting: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon and Title
            VStack(spacing: 16) {
                Image(systemName: "key.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("FocusKey")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            // Description
            VStack(spacing: 20) {
                Text("Focus with Purpose")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        icon: "iphone.and.arrow.forward",
                        title: "NFC Triggered Focus",
                        description: "Tap your phone on the FocusKey card to instantly start focus sessions"
                    )
                    
                    FeatureRow(
                        icon: "app.badge.checkmark",
                        title: "Smart App Blocking",
                        description: "Block distracting apps during work, study, or sleep time"
                    )
                    
                    FeatureRow(
                        icon: "timer",
                        title: "Break Management",
                        description: "Take controlled breaks without losing focus momentum"
                    )
                    
                    FeatureRow(
                        icon: "lock.shield",
                        title: "Privacy First",
                        description: "All data stays on your device using Apple's Screen Time APIs"
                    )
                }
            }
            
            Spacer()
            
            // Authorization Request
            VStack(spacing: 16) {
                Text("FocusKey uses Apple's Screen Time features to block distractions. You'll be asked to allow this.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: onRequestAuth) {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isRequesting ? "Requesting Permission..." : "Enable FocusKey")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isRequesting)
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AuthorizationDeniedView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            VStack(spacing: 16) {
                Text("Permission Required")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("FocusKey needs Screen Time permission to block apps during focus sessions.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                Text("To enable:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Go to Settings → Screen Time")
                    Text("2. Find FocusKey in the app list")
                    Text("3. Enable permissions for FocusKey")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
                         .padding()
             .background(Color(red: 0.95, green: 0.95, blue: 0.97))
             .cornerRadius(12)
            
            Spacer()
            
            Button("Open Settings") {
                #if os(iOS)
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                #endif
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }
}

struct MainAppView: View {
    var body: some View {
        TabView {
            FocusProfilesView()
                .tabItem {
                    Image(systemName: "circle.grid.3x3")
                    Text("Profiles")
                }
            
            SessionView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Focus")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("History")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

// Focus Profiles View with FamilyActivityPicker
struct FocusProfilesView: View {
    @State private var profiles: [FocusProfile] = FocusProfile.defaultProfiles
    @State private var selectedProfile: FocusProfile?
    @State private var showingAppPicker = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(profiles) { profile in
                    ProfileRow(profile: profile) {
                        selectedProfile = profile
                        showingAppPicker = true
                    }
                }
            }
            .navigationTitle("Focus Profiles")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        #if os(iOS)
        .familyActivityPicker(
            isPresented: $showingAppPicker,
            selection: Binding(
                get: { selectedProfile?.activitySelection ?? FamilyActivitySelection() },
                set: { newSelection in
                    if let index = profiles.firstIndex(where: { $0.id == selectedProfile?.id }) {
                        profiles[index].activitySelection = newSelection
                    }
                }
            )
        )
        #endif
    }
}

struct ProfileRow: View {
    let profile: FocusProfile
    let onTapSelectApps: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Header
            HStack {
                Image(systemName: profile.icon)
                    .font(.title2)
                    .foregroundColor(profile.color)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(profile.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    #if os(iOS)
                    if !profile.activitySelection.applicationTokens.isEmpty ||
                       !profile.activitySelection.categoryTokens.isEmpty ||
                       !profile.activitySelection.webDomainTokens.isEmpty {
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        Text("Configured")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                            .font(.title3)
                        
                        Text("Not Set")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    #else
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.title3)
                    
                    Text("iOS Only")
                        .font(.caption)
                        .foregroundColor(.gray)
                    #endif
                }
            }
            
            // Configuration Details
            HStack(spacing: 16) {
                ConfigDetail(
                    icon: "clock",
                    title: "Breaks",
                    value: profile.allowedBreaks == 0 ? "None" : "\(profile.allowedBreaks)"
                )
                
                ConfigDetail(
                    icon: "timer",
                    title: "Duration",
                    value: profile.allowedBreaks == 0 ? "—" : "\(profile.breakDuration)m"
                )
                
                Spacer()
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onTapSelectApps) {
                    HStack {
                        Image(systemName: "app.badge")
                        Text("Select Apps")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(profile.color.opacity(0.1))
                    .foregroundColor(profile.color)
                    .cornerRadius(8)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .foregroundColor(.secondary)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ConfigDetail: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
    }
}

struct SessionView: View {
    @StateObject private var sessionManager = FocusSessionManager.shared
    @State private var profiles: [FocusProfile] = FocusProfile.defaultProfiles
    @State private var selectedProfile: FocusProfile?
    @State private var showingProfilePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if sessionManager.isSessionActive {
                    ActiveSessionView(sessionManager: sessionManager)
                } else {
                    IdleSessionView(
                        profiles: profiles,
                        onStartSession: startSession
                    )
                }
            }
            .padding()
            .navigationTitle("Focus")
        }
        .sheet(isPresented: $showingProfilePicker) {
            ProfilePickerSheet(
                profiles: profiles,
                selectedProfile: $selectedProfile,
                onStart: { profile in
                    selectedProfile = profile
                    showingProfilePicker = false
                    Task {
                        await startSessionWithProfile(profile)
                    }
                }
            )
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func startSession() {
        showingProfilePicker = true
    }
    
    private func startSessionWithProfile(_ profile: FocusProfile) async {
        do {
            try await sessionManager.startFocusSession(with: profile)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

struct IdleSessionView: View {
    let profiles: [FocusProfile]
    let onStartSession: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Focus illustration
            VStack(spacing: 16) {
                Image(systemName: "target")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Ready to Focus")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Choose a profile to start blocking distracting apps")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Quick profile previews
            VStack(alignment: .leading, spacing: 12) {
                Text("Available Profiles")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                ForEach(profiles.prefix(3), id: \.id) { profile in
                    HStack {
                        Image(systemName: profile.icon)
                            .foregroundColor(profile.color)
                            .frame(width: 20)
                        
                        Text(profile.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(profile.allowedBreaks) breaks")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .cornerRadius(12)
            
            Spacer()
            
            // Start button
            Button(action: onStartSession) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Focus Session")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .font(.headline)
            }
        }
    }
}

struct ActiveSessionView: View {
    @ObservedObject var sessionManager: FocusSessionManager
    @State private var currentTime = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Session status
            VStack(spacing: 16) {
                if sessionManager.isOnBreak {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("On Break")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    if let timeRemaining = sessionManager.breakTimeRemaining {
                        Text("Break ends in \(formatTime(timeRemaining))")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Focusing")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    if let profile = sessionManager.currentProfile {
                        Text(profile.name + " Mode")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Session duration
                if let duration = sessionManager.sessionDuration {
                    Text("Session: \(formatTime(duration))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Break info
            if let profile = sessionManager.currentProfile, !sessionManager.isOnBreak {
                VStack(spacing: 12) {
                    Text("Breaks")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 16) {
                        Text("Used: \(sessionManager.breaksUsed)/\(profile.allowedBreaks)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if profile.breakDuration > 0 {
                            Text("Duration: \(profile.breakDuration)m")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                .cornerRadius(12)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                if !sessionManager.isOnBreak && sessionManager.canTakeBreak() {
                    Button("Take a Break") {
                        Task {
                            try? await sessionManager.startBreak()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
                }
                
                if sessionManager.isOnBreak {
                    Button("End Break Early") {
                        Task {
                            try? await sessionManager.endBreak()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(12)
                }
                
                Button("End Session") {
                    Task {
                        try? await sessionManager.endFocusSession()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

struct ProfilePickerSheet: View {
    let profiles: [FocusProfile]
    @Binding var selectedProfile: FocusProfile?
    let onStart: (FocusProfile) -> Void
    
    var body: some View {
        NavigationView {
            List(profiles) { profile in
                Button(action: { onStart(profile) }) {
                    HStack {
                        Image(systemName: profile.icon)
                            .foregroundColor(profile.color)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(profile.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            if profile.allowedBreaks > 0 {
                                Text("\(profile.allowedBreaks) breaks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(profile.breakDuration)m each")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("No breaks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Choose Profile")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

struct HistoryView: View {
    @EnvironmentObject var sessionManager: FocusSessionManager
    
    var body: some View {
        NavigationView {
            // Temporary: Show placeholder until SwiftData is fully integrated
            VStack(spacing: 20) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Session History")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("📊 Beautiful session analytics coming soon!\n\n✅ SwiftData persistence layer ready\n✅ Session tracking models created\n✅ Weekly stats and focus efficiency\n✅ Today/This Week/Older organization")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                if sessionManager.isSessionActive {
                    VStack(spacing: 8) {
                        Text("Active Session")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("Profile: \(sessionManager.currentProfile?.name ?? "Unknown")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Your current session will appear in history once completed!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .navigationTitle("History")
        }
    }
}

// TODO: SessionHistoryRow, WeeklyStatsView, and StatCard will be re-added when SwiftData is fully integrated

struct SettingsView: View {
    @EnvironmentObject var sessionManager: FocusSessionManager
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private func showAlert(_ title: String, _ message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("NFC Testing") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Current Status Indicator
                        HStack {
                            Circle()
                                .fill(sessionManager.isSessionActive ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)
                            
                            Text(sessionManager.isSessionActive ? 
                                 (sessionManager.isOnBreak ? "🔄 On Break" : "🔴 Session Active") : 
                                 "⚫ No Session")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        if sessionManager.isSessionActive {
                            Text("Profile: \(sessionManager.currentProfile?.name ?? "Unknown")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Test NFC triggers without physical cards")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            Button("🚀 Simulate NFC Start") {
                                simulateUniversalLink(path: "/start")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                            
                            Button("🔄 Simulate NFC Toggle") {
                                simulateUniversalLink(path: "/toggle")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                            
                            Button("☕ Simulate NFC Break") {
                                simulateUniversalLink(path: "/break")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("App Information") {
                    InfoRow(title: "Version", value: "1.0.0 (Beta)")
                    InfoRow(title: "Build", value: "1")
                    InfoRow(title: "Screen Time", 
                           value: sessionManager.isAuthorized ? "Authorized" : "Not Authorized")
                }
                
                Section("NFC Setup Instructions") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Physical NFC Card Setup")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                Text("1.")
                                    .fontWeight(.medium)
                                    .frame(width: 20, alignment: .leading)
                                Text("Get an NFC card/tag (NTAG213 or similar)")
                            }
                            
                            HStack(alignment: .top) {
                                Text("2.")
                                    .fontWeight(.medium)
                                    .frame(width: 20, alignment: .leading)
                                Text("Write URL: https://focuskey.app/toggle")
                            }
                            
                            HStack(alignment: .top) {
                                Text("3.")
                                    .fontWeight(.medium)
                                    .frame(width: 20, alignment: .leading)
                                Text("Tap card on iPhone to trigger focus")
                            }
                            
                            HStack(alignment: .top) {
                                Text("4.")
                                    .fontWeight(.medium)
                                    .frame(width: 20, alignment: .leading)
                                Text("Works on iPhone Xs and later")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FocusKey helps you stay focused by blocking distracting apps using Apple's Screen Time APIs.")
                        
                        Text("All data stays on your device. No tracking, no cloud storage without your permission.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
            .alert("NFC Simulation", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func simulateUniversalLink(path: String) {
        guard let url = URL(string: "https://focuskey.app\(path)") else { return }
        
        print("🧪 Simulating NFC trigger: \(url)")
        
        // Add haptic feedback to simulate NFC tap
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
        
        // For testing, we can directly call the handler
        Task { @MainActor in
            await simulateNFCTrigger(from: url)
        }
    }
    
    @MainActor
    private func simulateNFCTrigger(from url: URL) async {
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
            print("📱 Session active - would show confirmation dialog")
            showAlert("Session Already Active", "A focus session is already running. Use 'Toggle' to end it.")
        } else {
            await startWithDefaultProfile()
        }
    }
    
    @MainActor
    private func handleToggleTrigger() async {
        if sessionManager.isSessionActive {
            do {
                try await sessionManager.endFocusSession()
                print("🔴 Session ended via simulated NFC")
                showAlert("Session Ended! 🔴", "Your focus session has been stopped via NFC trigger.")
            } catch {
                print("❌ Error ending session: \(error)")
                showAlert("Error", "Failed to end session: \(error.localizedDescription)")
            }
        } else {
            await startWithDefaultProfile()
        }
    }
    
    @MainActor
    private func handleBreakTrigger() async {
        if sessionManager.isSessionActive && !sessionManager.isOnBreak {
            if sessionManager.canTakeBreak() {
                do {
                    try await sessionManager.startBreak()
                    print("☕ Break started via simulated NFC")
                    showAlert("Break Started! ☕", "Enjoy your 5-minute break. Apps are temporarily unblocked.")
                } catch {
                    print("❌ Error starting break: \(error)")
                    showAlert("Error", "Failed to start break: \(error.localizedDescription)")
                }
            } else {
                print("🚫 No breaks available")
                showAlert("No Breaks Available 🚫", "You've used all your breaks for this session.")
            }
        } else if !sessionManager.isSessionActive {
            showAlert("No Active Session", "Start a focus session first before taking a break.")
        } else if sessionManager.isOnBreak {
            showAlert("Already on Break ☕", "You're currently on a break! Return to focus or end session.")
        }
    }
    
    @MainActor
    private func startWithDefaultProfile() async {
        let defaultProfile = FocusProfile.defaultProfiles.first { $0.name == "Work" } 
                           ?? FocusProfile.defaultProfiles.first
        
        guard let profile = defaultProfile else {
            print("❌ No profiles available")
            return
        }
        
        do {
            try await sessionManager.startFocusSession(with: profile)
            print("🚀 Session started with \(profile.name) profile via simulated NFC")
            showAlert("Session Started! 🚀", "Focus session active with \(profile.name) profile. Selected apps are now blocked!")
        } catch {
            print("❌ Error starting session: \(error)")
            showAlert("Error", "Failed to start session: \(error.localizedDescription)")
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
