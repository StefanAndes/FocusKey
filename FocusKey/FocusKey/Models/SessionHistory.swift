import Foundation
import SwiftData
#if os(iOS)
import FamilyControls
#endif

@Model
class SessionHistory {
    var id: UUID
    var profileName: String
    var startTime: Date
    var endTime: Date?
    var totalFocusTime: TimeInterval // Total time actually focused (excluding breaks)
    var breaksTaken: Int
    var totalBreakTime: TimeInterval
    var wasCompletedNaturally: Bool // True if session ended normally, false if force-ended
    var triggerMethod: String // "manual", "nfc", "scheduled"
    
    // Computed properties
    var totalSessionTime: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    var isActive: Bool {
        return endTime == nil
    }
    
    var focusEfficiency: Double {
        guard totalSessionTime > 0 else { return 0 }
        return totalFocusTime / totalSessionTime
    }
    
    init(profileName: String, triggerMethod: String = "manual") {
        self.id = UUID()
        self.profileName = profileName
        self.startTime = Date()
        self.endTime = nil
        self.totalFocusTime = 0
        self.breaksTaken = 0
        self.totalBreakTime = 0
        self.wasCompletedNaturally = false
        self.triggerMethod = triggerMethod
    }
    
    func endSession(naturally: Bool = true) {
        self.endTime = Date()
        self.wasCompletedNaturally = naturally
    }
    
    func addBreak(duration: TimeInterval) {
        self.breaksTaken += 1
        self.totalBreakTime += duration
    }
    
    func updateFocusTime() {
        guard let endTime = endTime else {
            // Session still active, calculate up to now
            self.totalFocusTime = Date().timeIntervalSince(startTime) - totalBreakTime
            return
        }
        self.totalFocusTime = endTime.timeIntervalSince(startTime) - totalBreakTime
    }
} 