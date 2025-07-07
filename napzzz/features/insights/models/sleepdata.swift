//
//  sleepdata.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import Foundation

struct SleepData: Identifiable {
    let id = UUID()
    let date: Date
    let bedtime: Date
    let wakeTime: Date
    let sleepQuality: SleepQuality
    let sleepPhases: [SleepPhase]
    let detectedSounds: [DetectedSound]
    let sleepGoal: TimeInterval // in seconds
    let actualSleepTime: TimeInterval // in seconds
    
    var totalSleepTime: TimeInterval {
        return wakeTime.timeIntervalSince(bedtime)
    }
    
    var sleepGoalProgress: Double {
        return actualSleepTime / sleepGoal
    }
    
    var timeAwayFromGoal: TimeInterval {
        return sleepGoal - actualSleepTime
    }
}

enum SleepQuality: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .fair: return "orange"
        case .poor: return "red"
        }
    }
    
    var score: Double {
        switch self {
        case .excellent: return 0.9
        case .good: return 0.7
        case .fair: return 0.5
        case .poor: return 0.3
        }
    }
}

struct SleepPhase: Identifiable {
    let id = UUID()
    let type: SleepPhaseType
    let startTime: Date
    let duration: TimeInterval
    
    var endTime: Date {
        return startTime.addingTimeInterval(duration)
    }
}

enum SleepPhaseType: String, CaseIterable {
    case awake = "Awake"
    case light = "Light"
    case deep = "Deep"
    case rem = "Dream"
    
    var color: String {
        switch self {
        case .awake: return "orange"
        case .light: return "purple"
        case .deep: return "blue"
        case .rem: return "pink"
        }
    }
    
    var displayName: String {
        return self.rawValue
    }
}

struct DetectedSound: Identifiable {
    let id = UUID()
    let type: SoundType
    let timestamp: Date
    let intensity: Double // 0.0 to 1.0
    let duration: TimeInterval
}

enum SoundType: String, CaseIterable {
    case snoring = "Snoring"
    case noise = "Noise"
    case talking = "Talking"
    case movement = "Movement"
    
    var emoji: String {
        switch self {
        case .snoring: return "😴"
        case .noise: return "💥"
        case .talking: return "💬"
        case .movement: return "🏃"
        }
    }
    
    var icon: String {
        switch self {
        case .snoring: return "zzz"
        case .noise: return "speaker.wave.3.fill"
        case .talking: return "bubble.left.fill"
        case .movement: return "figure.walk"
        }
    }
}
