//
//  ContentView.swift
//  FocusKey
//
//  Created by Stefan Andelkovic on 2025-07-28.
//

import SwiftUI
import SwiftData
import UserNotifications
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
    @State private var showingCreateProfile = false
    @State private var editingProfile: FocusProfile?
    
    var body: some View {
        NavigationView {
            List {
                Section("Your Profiles") {
                    ForEach(profiles) { profile in
                        ProfileRow(profile: profile, onTapSelectApps: {
                            selectedProfile = profile
                            showingAppPicker = true
                        }, onEdit: {
                            editingProfile = profile
                        }, onDelete: {
                            deleteProfile(profile)
                        })
                    }
                    .onDelete(perform: deleteProfiles)
                }
                
                Section {
                    Button(action: {
                        showingCreateProfile = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Create New Profile")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Design a custom focus profile")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
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
        .sheet(isPresented: $showingCreateProfile) {
            SimpleProfileCreationView(profiles: $profiles)
        }
        .sheet(item: $editingProfile) { profile in
            ProfileScheduleSheet(profile: profile, profiles: $profiles) {
                editingProfile = nil
            }
        }
    }
    
    private func deleteProfile(_ profile: FocusProfile) {
        profiles.removeAll { $0.id == profile.id }
    }
    
    private func deleteProfiles(offsets: IndexSet) {
        profiles.remove(atOffsets: offsets)
    }
}

struct ProfileRow: View {
    let profile: FocusProfile
    let onTapSelectApps: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
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
                    title: "Break Time",
                    value: profile.allowedBreaks == 0 ? "—" : "\(profile.breakDuration)m"
                )
                
                ConfigDetail(
                    icon: "calendar.badge.clock",
                    title: "Schedule",
                    value: profile.isScheduled ? "Active" : "Manual"
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
                
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                        Text("Schedule")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(profile.isScheduled ? profile.color.opacity(0.1) : Color(red: 0.95, green: 0.95, blue: 0.97))
                    .foregroundColor(profile.isScheduled ? profile.color : .secondary)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(profile.isScheduled ? profile.color.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
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
    @State private var floatingAnimation = false
    @State private var selectedQuickProfile: FocusProfile?
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated focus illustration
            VStack(spacing: 20) {
                ZStack {
                    // Floating background circles
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 120 - CGFloat(index * 20), height: 120 - CGFloat(index * 20))
                            .scaleEffect(floatingAnimation ? 1.1 : 0.9)
                            .animation(
                                .easeInOut(duration: 2 + Double(index))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.3),
                                value: floatingAnimation
                            )
                    }
                    
                    // Center target icon
                    Image(systemName: "target")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                        .scaleEffect(floatingAnimation ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floatingAnimation)
                }
                
                Text("Ready to Focus")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Choose a profile to start your focus session\nand block distracting apps")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            // Quick profile selection cards
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Quick Start")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("Tap to preview")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: min(3, profiles.count)), spacing: 12) {
                    ForEach(profiles.prefix(3), id: \.id) { profile in
                        QuickProfileCard(
                            profile: profile,
                            isSelected: selectedQuickProfile?.id == profile.id,
                            onTap: {
                                selectedQuickProfile = profile
                            }
                        )
                    }
                }
            }
            .padding()
            .background(Color(red: 0.98, green: 0.98, blue: 1.0))
            .cornerRadius(20)
            
            Spacer()
            
            // Enhanced start button
            VStack(spacing: 12) {
                Button(action: onStartSession) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        
                        Text("Choose Profile & Start")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .font(.headline)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                if selectedQuickProfile != nil {
                    Text("Or start with \(selectedQuickProfile?.name ?? "") profile above")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            floatingAnimation = true
        }
    }
}

struct QuickProfileCard: View {
    let profile: FocusProfile
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Profile icon with background
                ZStack {
                    Circle()
                        .fill(profile.color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: profile.icon)
                        .font(.title3)
                        .foregroundColor(profile.color)
                }
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                // Profile name
                Text(profile.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Break info
                Text("\(profile.allowedBreaks) breaks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? profile.color.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? profile.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActiveSessionView: View {
    @ObservedObject var sessionManager: FocusSessionManager
    @State private var currentTime = Date()
    @State private var pulseAnimation = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Circular Progress Ring
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: sessionProgress)
                    .stroke(
                        sessionManager.isOnBreak ? Color.orange : (sessionManager.currentProfile?.color ?? .blue),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: sessionProgress)
                
                // Center content
                VStack(spacing: 8) {
                    if sessionManager.isOnBreak {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.orange)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                        
                        Text("Break")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        if let timeRemaining = sessionManager.breakTimeRemaining {
                            Text(formatTime(timeRemaining))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    } else {
                        Image(systemName: sessionManager.currentProfile?.icon ?? "target")
                            .font(.system(size: 32))
                            .foregroundColor(sessionManager.currentProfile?.color ?? .blue)
                            .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseAnimation)
                        
                        Text("Focusing")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(sessionManager.currentProfile?.color ?? .blue)
                        
                        if let duration = sessionManager.sessionDuration {
                            Text(formatTime(duration))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            
            // Profile and Status Info
            VStack(spacing: 16) {
                if let profile = sessionManager.currentProfile {
                    HStack {
                        Image(systemName: profile.icon)
                            .font(.title3)
                            .foregroundColor(profile.color)
                            .frame(width: 24, height: 24)
                        
                        Text(profile.name + " Profile")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Session \(sessionNumber)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(sessionManager.isOnBreak ? Color.orange : Color.green)
                                    .frame(width: 8, height: 8)
                                
                                Text(sessionManager.isOnBreak ? "On Break" : "Active")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(sessionManager.isOnBreak ? .orange : .green)
                            }
                        }
                    }
                    .padding()
                    .background(profile.color.opacity(0.08))
                    .cornerRadius(16)
                }
            }
            
            // Break Statistics
            if let profile = sessionManager.currentProfile {
                HStack(spacing: 20) {
                    // Breaks Used
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            ForEach(0..<profile.allowedBreaks, id: \.self) { index in
                                Circle()
                                    .fill(index < sessionManager.breaksUsed ? Color.orange : Color.gray.opacity(0.3))
                                    .frame(width: 12, height: 12)
                                    .scaleEffect(index < sessionManager.breaksUsed ? 1.0 : 0.8)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: sessionManager.breaksUsed)
                            }
                        }
                        
                        Text("Breaks Used")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(sessionManager.breaksUsed)/\(profile.allowedBreaks)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    // Break Duration
                    if profile.allowedBreaks > 0 {
                        VStack(spacing: 8) {
                            Image(systemName: "timer")
                                .font(.title3)
                                .foregroundColor(.orange)
                            
                            Text("Break Time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(profile.breakDuration)m")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                    }
                    
                    // Apps Blocked
                    VStack(spacing: 8) {
                        Image(systemName: "app.badge")
                            .font(.title3)
                            .foregroundColor(.red)
                        
                        Text("Apps Blocked")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        #if os(iOS)
                        Text("\(profile.activitySelection.applicationTokens.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                        #else
                        Text("iOS Only")
                            .font(.caption)
                            .fontWeight(.semibold)
                        #endif
                    }
                }
                .padding()
                .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                .cornerRadius(16)
            }
            
            Spacer()
            
            // Enhanced Action buttons
            VStack(spacing: 16) {
                if !sessionManager.isOnBreak && sessionManager.canTakeBreak() {
                    Button(action: {
                        Task {
                            try? await sessionManager.startBreak()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Take a Break")
                                    .fontWeight(.semibold)
                                
                                Text("\(sessionManager.currentProfile?.breakDuration ?? 5) minutes")
                                    .font(.caption)
                                    .opacity(0.8)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange.opacity(0.15), Color.orange.opacity(0.05)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.orange)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                
                if sessionManager.isOnBreak {
                    Button(action: {
                        Task {
                            try? await sessionManager.endBreak()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("End Break Early")
                                    .fontWeight(.semibold)
                                
                                Text("Resume focusing")
                                    .font(.caption)
                                    .opacity(0.8)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green.opacity(0.15), Color.green.opacity(0.05)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.green)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                
                Button(action: {
                    Task {
                        try? await sessionManager.endFocusSession()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.circle.fill")
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("End Session")
                                .fontWeight(.semibold)
                            
                            Text("Save progress & unlock apps")
                                .font(.caption)
                                .opacity(0.8)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red.opacity(0.15), Color.red.opacity(0.05)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.red)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .onAppear {
            pulseAnimation = true
        }
    }
    
    // Calculate session progress (0.0 to 1.0)
    private var sessionProgress: Double {
        guard let duration = sessionManager.sessionDuration,
              let profile = sessionManager.currentProfile else {
            return 0.0
        }
        
        if sessionManager.isOnBreak {
            // Show break progress
            guard let breakStart = sessionManager.breakStartTime else { return 0.0 }
            let breakElapsed = Date().timeIntervalSince(breakStart)
            let totalBreakTime = TimeInterval(profile.breakDuration * 60)
            return min(1.0, breakElapsed / totalBreakTime)
        } else {
            // Show session progress (assuming 1 hour max for visual purposes)
            let maxDisplayTime: TimeInterval = 3600 // 1 hour
            return min(1.0, duration / maxDisplayTime)
        }
    }
    
    private var sessionNumber: Int {
        // This could be calculated from session history in the future
        return 1
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
    @Query(sort: \SessionHistory.startTime, order: .reverse) private var sessions: [SessionHistory]
    @EnvironmentObject var sessionManager: FocusSessionManager
    
    var body: some View {
        NavigationView {
            if sessions.isEmpty {
                // No sessions yet - show beautiful empty state
                VStack(spacing: 20) {
                    Image(systemName: "clock.badge")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Sessions Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Your focus sessions will appear here after you complete them")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    if !sessionManager.isSessionActive {
                        Button("Start Your First Session") {
                            // This could switch to Session tab in the future
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .navigationTitle("History")
            } else {
                // Show real session data
                List {
                    // Today's Sessions
                    let todaySessions = sessions.filter { Calendar.current.isDateInToday($0.startTime) }
                    if !todaySessions.isEmpty {
                        Section("Today") {
                                                         ForEach(todaySessions, id: \.id) { session in
                                 SessionHistoryCard(session: session)
                             }
                        }
                    }
                    
                    // This Week's Sessions
                    let thisWeekSessions = sessions.filter { 
                        !Calendar.current.isDateInToday($0.startTime) && 
                        Calendar.current.isDate($0.startTime, equalTo: Date(), toGranularity: .weekOfYear)
                    }
                    if !thisWeekSessions.isEmpty {
                        Section("This Week") {
                                                         ForEach(thisWeekSessions, id: \.id) { session in
                                 SessionHistoryCard(session: session)
                             }
                        }
                    }
                    
                    // Older Sessions
                    let olderSessions = sessions.filter { 
                        !Calendar.current.isDate($0.startTime, equalTo: Date(), toGranularity: .weekOfYear)
                    }
                    if !olderSessions.isEmpty {
                        Section("Older") {
                                                         ForEach(olderSessions, id: \.id) { session in
                                 SessionHistoryCard(session: session)
                             }
                        }
                    }
                    
                                         // Weekly Stats Dashboard
                     WeeklyStatsSection(sessions: sessions)
                }
                .navigationTitle("History")
            }
        }
    }
    
    private func formatSessionTime(_ session: SessionHistory) -> String {
        let duration = session.totalSessionTime
        let minutes = Int(duration) / 60
        return "\(minutes)m"
    }
}

struct SessionHistoryCard: View {
    let session: SessionHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with profile info and status
            HStack(alignment: .top) {
                // Profile Icon
                Image(systemName: profileIcon(for: session.profileName))
                    .font(.title2)
                    .foregroundColor(profileColor(for: session.profileName))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(profileColor(for: session.profileName).opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(session.profileName)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        if session.isActive {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("Active")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                            }
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: session.wasCompletedNaturally ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(session.wasCompletedNaturally ? .green : .orange)
                                
                                Text(session.wasCompletedNaturally ? "Completed" : "Interrupted")
                                    .font(.caption)
                                    .foregroundColor(session.wasCompletedNaturally ? .green : .orange)
                            }
                        }
                    }
                    
                    Text(formatTimeRange(session.startTime, session.endTime))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(triggerMethodText(session.triggerMethod))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Session Stats
            HStack(spacing: 20) {
                StatItem(
                    icon: "clock.fill",
                    title: "Duration",
                    value: formatDuration(session.totalSessionTime),
                    color: .blue
                )
                
                StatItem(
                    icon: "target",
                    title: "Focus Time",
                    value: formatDuration(session.totalFocusTime),
                    color: .green
                )
                
                if session.breaksTaken > 0 {
                    StatItem(
                        icon: "cup.and.saucer.fill",
                        title: "Breaks",
                        value: "\(session.breaksTaken)",
                        color: .orange
                    )
                }
                
                Spacer()
            }
            
            // Focus Efficiency Progress Bar
            if !session.isActive && session.totalSessionTime > 60 {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Focus Efficiency")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(session.focusEfficiency * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(efficiencyColor(session.focusEfficiency))
                    }
                    
                    ProgressView(value: session.focusEfficiency)
                        .progressViewStyle(LinearProgressViewStyle(tint: efficiencyColor(session.focusEfficiency)))
                        .scaleEffect(y: 0.8)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func profileIcon(for profileName: String) -> String {
        switch profileName {
        case "Work": return "briefcase.fill"
        case "Study": return "book.fill"
        case "Sleep": return "moon.fill"
        default: return "circle.fill"
        }
    }
    
    private func profileColor(for profileName: String) -> Color {
        switch profileName {
        case "Work": return .blue
        case "Study": return .purple
        case "Sleep": return .indigo
        default: return .gray
        }
    }
    
    private func formatTimeRange(_ start: Date, _ end: Date?) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if let end = end {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        } else {
            return "Started \(formatter.string(from: start))"
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func triggerMethodText(_ method: String) -> String {
        switch method {
        case "nfc": return "🏷️ Started via NFC"
        case "manual": return "📱 Started manually"
        case "scheduled": return "⏰ Auto-started"
        default: return "📱 Started manually"
        }
    }
    
    private func efficiencyColor(_ efficiency: Double) -> Color {
        if efficiency >= 0.8 { return .green }
        else if efficiency >= 0.6 { return .orange }
        else { return .red }
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 14)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
    }
}

struct WeeklyStatsSection: View {
    let sessions: [SessionHistory]
    
    private var weeklyStats: (totalTime: TimeInterval, totalFocusTime: TimeInterval, completedSessions: Int, averageEfficiency: Double, totalBreaks: Int) {
        let thisWeekSessions = sessions.filter { 
            Calendar.current.isDate($0.startTime, equalTo: Date(), toGranularity: .weekOfYear) && 
            $0.endTime != nil 
        }
        
        let totalTime = thisWeekSessions.reduce(0) { $0 + $1.totalSessionTime }
        let totalFocusTime = thisWeekSessions.reduce(0) { $0 + $1.totalFocusTime }
        let completedSessions = thisWeekSessions.count
        let averageEfficiency = thisWeekSessions.isEmpty ? 0 : thisWeekSessions.reduce(0) { $0 + $1.focusEfficiency } / Double(thisWeekSessions.count)
        let totalBreaks = thisWeekSessions.reduce(0) { $0 + $1.breaksTaken }
        
        return (totalTime, totalFocusTime, completedSessions, averageEfficiency, totalBreaks)
    }
    
    var body: some View {
        Section {
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This Week's Focus")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Your productivity at a glance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                // Stats Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    WeeklyStatCard(
                        icon: "clock.fill",
                        title: "Total Time",
                        value: formatDuration(weeklyStats.totalTime),
                        subtitle: "\(formatDuration(weeklyStats.totalFocusTime)) focused",
                        color: .blue,
                        progress: weeklyStats.totalTime > 0 ? weeklyStats.totalFocusTime / weeklyStats.totalTime : 0
                    )
                    
                    WeeklyStatCard(
                        icon: "target",
                        title: "Sessions",
                        value: "\(weeklyStats.completedSessions)",
                        subtitle: weeklyStats.completedSessions > 0 ? "avg \(Int(weeklyStats.averageEfficiency * 100))% efficiency" : "No sessions yet",
                        color: .green,
                        progress: weeklyStats.averageEfficiency
                    )
                    
                    WeeklyStatCard(
                        icon: "cup.and.saucer.fill",
                        title: "Breaks",
                        value: "\(weeklyStats.totalBreaks)",
                        subtitle: weeklyStats.completedSessions > 0 ? "avg \(String(format: "%.1f", Double(weeklyStats.totalBreaks) / Double(weeklyStats.completedSessions))) per session" : "—",
                        color: .orange,
                        progress: weeklyStats.totalBreaks > 0 ? min(1.0, Double(weeklyStats.totalBreaks) / 10.0) : 0
                    )
                    
                    WeeklyStatCard(
                        icon: "flame.fill",
                        title: "Efficiency",
                        value: "\(Int(weeklyStats.averageEfficiency * 100))%",
                        subtitle: efficiencyDescription(weeklyStats.averageEfficiency),
                        color: efficiencyColor(weeklyStats.averageEfficiency),
                        progress: weeklyStats.averageEfficiency
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
        }
    }
    
    private func efficiencyColor(_ efficiency: Double) -> Color {
        if efficiency >= 0.8 { return .green }
        else if efficiency >= 0.6 { return .orange }
        else { return .red }
    }
    
    private func efficiencyDescription(_ efficiency: Double) -> String {
        if efficiency >= 0.9 { return "Excellent!" }
        else if efficiency >= 0.8 { return "Great focus" }
        else if efficiency >= 0.6 { return "Good effort" }
        else if efficiency > 0 { return "Room to improve" }
        else { return "No data yet" }
    }
}

struct WeeklyStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Progress indicator
            ProgressView(value: min(1.0, max(0.0, progress)))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(y: 0.6)
        }
        .padding()
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
}

struct ProfileScheduleSheet: View {
    let profile: FocusProfile
    @Binding var profiles: [FocusProfile]
    let onDismiss: () -> Void
    
    @State private var isScheduled: Bool
    @State private var selectedDays: Set<FocusProfile.Weekday>
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var enableNotifications = true
    
    init(profile: FocusProfile, profiles: Binding<[FocusProfile]>, onDismiss: @escaping () -> Void) {
        self.profile = profile
        self._profiles = profiles
        self.onDismiss = onDismiss
        self._isScheduled = State(initialValue: profile.isScheduled)
        self._selectedDays = State(initialValue: profile.scheduleDays)
        self._startTime = State(initialValue: profile.scheduleStart ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date())
        self._endTime = State(initialValue: profile.scheduleEnd ?? Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Header
                Section {
                    HStack {
                        Image(systemName: profile.icon)
                            .font(.title2)
                            .foregroundColor(profile.color)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(profile.color.opacity(0.15))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(profile.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Schedule Toggle
                Section("Automatic Scheduling") {
                    Toggle("Enable Scheduled Sessions", isOn: $isScheduled)
                        .toggleStyle(SwitchToggleStyle(tint: profile.color))
                    
                    if isScheduled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your \(profile.name) sessions will start automatically based on the schedule below.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }
                }
                
                if isScheduled {
                    // Days Selection
                    Section("Days of the Week") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(FocusProfile.Weekday.allCases, id: \.self) { weekday in
                                DayToggleButton(
                                    weekday: weekday,
                                    isSelected: selectedDays.contains(weekday),
                                    color: profile.color
                                ) {
                                    if selectedDays.contains(weekday) {
                                        selectedDays.remove(weekday)
                                    } else {
                                        selectedDays.insert(weekday)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Time Settings
                    Section("Session Times") {
                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                        
                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Session Duration: \(formatTimeDifference(from: startTime, to: endTime))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Sessions will start and end automatically at these times.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    
                    // Notifications
                    Section("Notifications") {
                        Toggle("Notify before session starts", isOn: $enableNotifications)
                            .toggleStyle(SwitchToggleStyle(tint: profile.color))
                        
                        if enableNotifications {
                            Text("You'll receive a notification 5 minutes before your scheduled session begins.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }
                    
                    // Preview
                    Section("Schedule Preview") {
                        if !selectedDays.isEmpty {
                            ForEach(Array(selectedDays).sorted { $0.rawValue < $1.rawValue }, id: \.self) { day in
                                HStack {
                                    Text(day.rawValue)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("\(formatTime(startTime)) - \(formatTime(endTime))")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        } else {
                            Text("Select days to see your schedule")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
            }
            .navigationTitle("Schedule \(profile.name)")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSchedule()
                    }
                    .disabled(isScheduled && selectedDays.isEmpty)
                }
            }
        }
    }
    
    private func saveSchedule() {
        // Update the profile in the array
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index].isScheduled = isScheduled
            profiles[index].scheduleDays = selectedDays
            profiles[index].scheduleStart = isScheduled ? startTime : nil
            profiles[index].scheduleEnd = isScheduled ? endTime : nil
            
            // TODO: Schedule local notifications
            if isScheduled && enableNotifications {
                scheduleNotifications(for: profiles[index])
            }
        }
        
        onDismiss()
    }
    
    private func scheduleNotifications(for profile: FocusProfile) {
        guard profile.isScheduled else { return }
        
        // Request notification permission if needed
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.createScheduledNotifications(for: profile)
            } else {
                print("⚠️ Notification permission denied")
            }
        }
    }
    
    private func createScheduledNotifications(for profile: FocusProfile) {
        // Remove existing notifications for this profile
        let identifiers = profile.scheduleDays.map { "focus_\(profile.id)_\($0.rawValue)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        
        // Schedule new notifications
        for weekday in profile.scheduleDays {
            guard let startTime = profile.scheduleStart else { continue }
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: startTime)
            
            var notificationComponents = DateComponents()
            notificationComponents.weekday = weekday.calendarWeekday
            notificationComponents.hour = components.hour
            notificationComponents.minute = (components.minute ?? 0) - 5 // 5 minutes before
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: notificationComponents, repeats: true)
            
            let content = UNMutableNotificationContent()
            content.title = "Focus Session Starting Soon"
            content.body = "Your \(profile.name) session begins in 5 minutes!"
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(
                identifier: "focus_\(profile.id)_\(weekday.rawValue)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling notification: \(error)")
                } else {
                    print("✅ Scheduled notification for \(profile.name) on \(weekday.rawValue)")
                }
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatTimeDifference(from start: Date, to end: Date) -> String {
        let difference = end.timeIntervalSince(start)
        let hours = Int(difference) / 3600
        let minutes = Int(difference) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct DayToggleButton: View {
    let weekday: FocusProfile.Weekday
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(weekday.shortName)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? color.opacity(0.1) : Color(red: 0.95, green: 0.95, blue: 0.97))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? color.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
            .foregroundColor(isSelected ? color : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SimpleProfileCreationView: View {
    @Binding var profiles: [FocusProfile]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "circle.fill"
    @State private var selectedColor = Color.blue
    @State private var allowedBreaks = 2
    @State private var breakDuration = 5
    
    private let availableIcons = [
        "briefcase.fill", "book.fill", "moon.fill", "gamecontroller.fill",
        "music.note", "paintbrush.fill", "dumbbell.fill", "heart.fill"
    ]
    
    private let availableColors: [Color] = [
        .blue, .purple, .pink, .red, .orange, .yellow, .green, .mint
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Details") {
                    TextField("Profile Name", text: $name)
                    TextField("Description", text: $description)
                }
                
                Section("Appearance") {
                    VStack(alignment: .leading) {
                        Text("Icon")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button(action: {
                                    selectedIcon = icon
                                }) {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? selectedColor : .gray)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle()
                                                .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Color")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                            ForEach(availableColors, id: \.self) { color in
                                Button(action: {
                                    selectedColor = color
                                }) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                Section("Settings") {
                    Stepper("Allowed Breaks: \(allowedBreaks)", value: $allowedBreaks, in: 0...5)
                    
                    if allowedBreaks > 0 {
                        Stepper("Break Duration: \(breakDuration) min", value: $breakDuration, in: 1...15)
                    }
                }
                
                Section("Preview") {
                    HStack {
                        Image(systemName: selectedIcon)
                            .font(.title2)
                            .foregroundColor(selectedColor)
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(name.isEmpty ? "My Focus Profile" : name)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(description.isEmpty ? "Custom focus profile" : description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Profile")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveProfile() {
        let newProfile = FocusProfile(
            name: name.isEmpty ? "My Focus Profile" : name,
            icon: selectedIcon,
            color: selectedColor,
            description: description.isEmpty ? "Custom focus profile" : description,
            allowedBreaks: allowedBreaks,
            breakDuration: breakDuration
        )
        
        profiles.append(newProfile)
        presentationMode.wrappedValue.dismiss()
    }
}

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
            try await sessionManager.startFocusSession(with: profile, triggerMethod: "nfc")
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
