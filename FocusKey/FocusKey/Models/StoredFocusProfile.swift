import Foundation
import SwiftData
import SwiftUI
#if os(iOS)
import FamilyControls
import UIKit
#endif

@Model
class StoredFocusProfile {
    var id: UUID
    var name: String
    var iconName: String
    var colorRed: Double
    var colorGreen: Double
    var colorBlue: Double
    var profileDescription: String
    var allowedBreaks: Int
    var breakDuration: TimeInterval
    var maxSessionDuration: TimeInterval
    var isDefault: Bool
    var createdAt: Date
    var lastUsed: Date?
    
    // Store app selection as Data (encoded)
    #if os(iOS)
    var activitySelectionData: Data?
    #endif
    
    // Schedule data (simplified for now)
    var scheduleEnabled: Bool
    var scheduleDays: String // Comma-separated weekday numbers
    var scheduleStartTime: Date?
    var scheduleEndTime: Date?
    
    init(name: String, iconName: String, color: (Double, Double, Double), description: String, allowedBreaks: Int = 2, breakDuration: TimeInterval = 300, maxSessionDuration: TimeInterval = 3600) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.colorRed = color.0
        self.colorGreen = color.1
        self.colorBlue = color.2
        self.profileDescription = description
        self.allowedBreaks = allowedBreaks
        self.breakDuration = breakDuration
        self.maxSessionDuration = maxSessionDuration
        self.isDefault = false
        self.createdAt = Date()
        self.lastUsed = nil
        self.scheduleEnabled = false
        self.scheduleDays = ""
        self.scheduleStartTime = nil
        self.scheduleEndTime = nil
        
        #if os(iOS)
        self.activitySelectionData = nil
        #endif
    }
    
    // TODO: Add conversion methods after integrating with FocusProfile
    
    static func createDefaultProfiles() -> [StoredFocusProfile] {
        return [
            StoredFocusProfile(
                name: "Work",
                iconName: "briefcase.fill",
                color: (0.0, 0.5, 1.0),
                description: "Block social media and games during work hours",
                allowedBreaks: 2,
                breakDuration: 300,
                maxSessionDuration: 3600
            ),
            StoredFocusProfile(
                name: "Study",
                iconName: "book.fill",
                color: (0.6, 0.2, 0.8),
                description: "Focus mode for learning and studying",
                allowedBreaks: 3,
                breakDuration: 600,
                maxSessionDuration: 7200
            ),
            StoredFocusProfile(
                name: "Sleep",
                iconName: "moon.fill",
                color: (0.2, 0.2, 0.4),
                description: "Block all apps for better sleep hygiene",
                allowedBreaks: 0,
                breakDuration: 0,
                maxSessionDuration: 28800
            )
        ]
    }
}

// MARK: - Color Extension
import SwiftUI

extension Color {
    init(red: Double, green: Double, blue: Double) {
        self.init(red: red, green: green, blue: blue, opacity: 1.0)
    }
} 