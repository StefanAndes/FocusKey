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

// Placeholder views for main app sections
struct FocusProfilesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Focus Profiles")
                    .font(.title)
                Text("Work, Study, Sleep profiles coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Profiles")
        }
    }
}

struct SessionView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Focus Session")
                    .font(.title)
                Text("Session controls coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Focus")
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
