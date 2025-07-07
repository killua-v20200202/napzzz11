//
//  sleeptracker.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import Foundation
import SwiftUI

struct SleepSchedule: Identifiable {
    let id = UUID()
    var bedtime: Date
    var wakeTime: Date
    var isEnabled: Bool = true
    
    var sleepDuration: TimeInterval {
        let calendar = Calendar.current
        let bedtimeComponents = calendar.dateComponents([.hour, .minute], from: bedtime)
        let wakeTimeComponents = calendar.dateComponents([.hour, .minute], from: wakeTime)
        
        let bedtimeMinutes = (bedtimeComponents.hour ?? 0) * 60 + (bedtimeComponents.minute ?? 0)
        let wakeTimeMinutes = (wakeTimeComponents.hour ?? 0) * 60 + (wakeTimeComponents.minute ?? 0)
        
        var duration = wakeTimeMinutes - bedtimeMinutes
        if duration <= 0 {
            duration += 24 * 60 // Add 24 hours if wake time is next day
        }
        
        return TimeInterval(duration * 60) // Convert to seconds
    }
    
    var formattedSleepDuration: String {
        let hours = Int(sleepDuration) / 3600
        let minutes = Int(sleepDuration) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
}

enum SleepActivity: String, CaseIterable, Identifiable {
    case sleepingPill = "Sleeping pill"
    case alcohol = "Alcohol"
    case workout = "Workout"
    case stretch = "Stretch"
    case ateLate = "Ate late"
    case underStress = "Under stress"
    case coffee = "Coffee"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .sleepingPill: return "💊"
        case .alcohol: return "🍺"
        case .workout: return "🏃"
        case .stretch: return "🤸"
        case .ateLate: return "🍽️"
        case .underStress: return "😰"
        case .coffee: return "☕"
        }
    }
    
    var icon: String {
        switch self {
        case .sleepingPill: return "pills.fill"
        case .alcohol: return "wineglass.fill"
        case .workout: return "figure.run"
        case .stretch: return "figure.flexibility"
        case .ateLate: return "fork.knife"
        case .underStress: return "exclamationmark.triangle.fill"
        case .coffee: return "cup.and.saucer.fill"
        }
    }
}

enum AlarmTone: String, CaseIterable, Identifiable {
    case gentle = "Gentle"
    case nature = "Nature"
    case classic = "Classic"
    case energetic = "Energetic"
    case peaceful = "Peaceful"
    
    var id: String { rawValue }
    
    var fileName: String {
        switch self {
        case .gentle: return "gentle_alarm.mp3"
        case .nature: return "nature_alarm.mp3"
        case .classic: return "classic_alarm.mp3"
        case .energetic: return "energetic_alarm.mp3"
        case .peaceful: return "peaceful_alarm.mp3"
        }
    }
    
    var description: String {
        switch self {
        case .gentle: return "Soft chimes"
        case .nature: return "Birds & water"
        case .classic: return "Traditional bell"
        case .energetic: return "Upbeat melody"
        case .peaceful: return "Calm tones"
        }
    }
}
