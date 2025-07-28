//
//  ContentView.swift
//  FocusKey
//
//  Created by Stefan Andelkovic on 2025-07-28.
//

import SwiftUI
#if os(iOS)
import FamilyControls
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
    var body: some View {
        NavigationView {
            VStack {
                Text("Focus History")
                    .font(.title)
                Text("Session analytics coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("History")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(.title)
                Text("App settings coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
