//
//  FocusProfile.swift
//  FocusKey
//
//  Created by Stefan Andelkovic on 2025-01-05.
//

import SwiftUI
#if os(iOS)
import FamilyControls
import UIKit
#endif

struct FocusProfile: Codable, Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var color: Color
    var description: String
    
    #if os(iOS)
    var activitySelection: FamilyActivitySelection
    #endif
    
    var allowedBreaks: Int
    var breakDuration: Int // minutes
    var isScheduled: Bool
    var scheduleStart: Date?
    var scheduleEnd: Date?
    var scheduleDays: Set<Weekday>
    
    enum Weekday: String, CaseIterable, Codable {
        case monday = "Monday"
        case tuesday = "Tuesday" 
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
        
        var shortName: String {
            String(rawValue.prefix(3))
        }
        
        var calendarWeekday: Int {
            switch self {
            case .sunday: return 1
            case .monday: return 2
            case .tuesday: return 3
            case .wednesday: return 4
            case .thursday: return 5
            case .friday: return 6
            case .saturday: return 7
            }
        }
    }
    
    // Custom Codable implementation to handle Color
    enum CodingKeys: CodingKey {
        case name, icon, description, allowedBreaks, breakDuration
        case isScheduled, scheduleStart, scheduleEnd, scheduleDays
        #if os(iOS)
        case activitySelection
        #endif
        case colorRed, colorGreen, colorBlue, colorOpacity
    }
    
    init(
        name: String,
        icon: String,
        color: Color,
        description: String,
        allowedBreaks: Int = 1,
        breakDuration: Int = 5,
        isScheduled: Bool = false,
        scheduleStart: Date? = nil,
        scheduleEnd: Date? = nil,
        scheduleDays: Set<Weekday> = []
    ) {
        self.name = name
        self.icon = icon
        self.color = color
        self.description = description
        self.allowedBreaks = allowedBreaks
        self.breakDuration = breakDuration
        self.isScheduled = isScheduled
        self.scheduleStart = scheduleStart
        self.scheduleEnd = scheduleEnd
        self.scheduleDays = scheduleDays
        
        #if os(iOS)
        self.activitySelection = FamilyActivitySelection()
        #endif
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        description = try container.decode(String.self, forKey: .description)
        allowedBreaks = try container.decode(Int.self, forKey: .allowedBreaks)
        breakDuration = try container.decode(Int.self, forKey: .breakDuration)
        isScheduled = try container.decode(Bool.self, forKey: .isScheduled)
        scheduleStart = try container.decodeIfPresent(Date.self, forKey: .scheduleStart)
        scheduleEnd = try container.decodeIfPresent(Date.self, forKey: .scheduleEnd)
        scheduleDays = try container.decode(Set<Weekday>.self, forKey: .scheduleDays)
        
        // Decode color components
        let red = try container.decode(Double.self, forKey: .colorRed)
        let green = try container.decode(Double.self, forKey: .colorGreen)
        let blue = try container.decode(Double.self, forKey: .colorBlue)
        let opacity = try container.decode(Double.self, forKey: .colorOpacity)
        color = Color(red: red, green: green, blue: blue, opacity: opacity)
        
        #if os(iOS)
        activitySelection = try container.decode(FamilyActivitySelection.self, forKey: .activitySelection)
        #endif
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(description, forKey: .description)
        try container.encode(allowedBreaks, forKey: .allowedBreaks)
        try container.encode(breakDuration, forKey: .breakDuration)
        try container.encode(isScheduled, forKey: .isScheduled)
        try container.encodeIfPresent(scheduleStart, forKey: .scheduleStart)
        try container.encodeIfPresent(scheduleEnd, forKey: .scheduleEnd)
        try container.encode(scheduleDays, forKey: .scheduleDays)
        
        // Encode color components
        #if os(iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        try container.encode(Double(red), forKey: .colorRed)
        try container.encode(Double(green), forKey: .colorGreen)
        try container.encode(Double(blue), forKey: .colorBlue)
        try container.encode(Double(alpha), forKey: .colorOpacity)
        #else
        // Fallback for non-iOS platforms
        try container.encode(0.0, forKey: .colorRed)
        try container.encode(0.0, forKey: .colorGreen) 
        try container.encode(1.0, forKey: .colorBlue)
        try container.encode(1.0, forKey: .colorOpacity)
        #endif
        
        #if os(iOS)
        try container.encode(activitySelection, forKey: .activitySelection)
        #endif
    }
    
    // Predefined profiles
    static var defaultProfiles: [FocusProfile] {
        [
            FocusProfile(
                name: "Work",
                icon: "briefcase.fill",
                color: .blue,
                description: "Block social media and entertainment during work hours",
                allowedBreaks: 2,
                breakDuration: 10
            ),
            FocusProfile(
                name: "Study",
                icon: "book.fill", 
                color: .green,
                description: "Eliminate distractions while learning and studying",
                allowedBreaks: 1,
                breakDuration: 5
            ),
            FocusProfile(
                name: "Sleep",
                icon: "moon.fill",
                color: .purple,
                description: "Wind down by blocking stimulating apps before bed",
                allowedBreaks: 0,
                breakDuration: 0
            )
        ]
    }
} 