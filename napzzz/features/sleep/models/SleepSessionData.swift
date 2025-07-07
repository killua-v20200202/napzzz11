//
//  SleepSessionData.swift
//  napzzz
//
//  Created by Morris Romagnoli on 07/07/2025.
//

import Foundation

struct SleepSessionData: Identifiable {
    let id = UUID()
    let date: Date
    let startTime: Date
    let endTime: Date
    let sleepPhases: [SleepPhaseData]
    let detectedSounds: [SoundEvent]
    let ambientNoise: [NoiseReading]
    let sleepQuality: SleepQualityScore
    let sleepGoal: TimeInterval
    
    var totalSleepTime: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    var actualSleepTime: TimeInterval {
        return sleepPhases.filter { $0.type != .awake }.reduce(0) { $0 + $1.duration }
    }
    
    var timeInBed: TimeInterval {
        return totalSleepTime
    }
    
    var sleepEfficiency: Double {
        return actualSleepTime / totalSleepTime
    }
    
    var averageNoiseLevel: Double {
        return ambientNoise.isEmpty ? 0 : ambientNoise.map { $0.level }.reduce(0, +) / Double(ambientNoise.count)
    }
}

struct SleepPhaseData: Identifiable {
    let id = UUID()
    let type: SleepPhaseType
    let startTime: Date
    let duration: TimeInterval
    
    var endTime: Date {
        return startTime.addingTimeInterval(duration)
    }
    
    var percentage: Double = 0.0
}

struct SleepQualityScore {
    let score: Int // 0-100
    let rating: SleepQualityRating
    
    var description: String {
        switch rating {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        case .tooShort: return "Too short"
        }
    }
    
    var color: String {
        switch rating {
        case .excellent: return "green"
        case .good: return "blue"
        case .fair: return "orange"
        case .poor, .tooShort: return "red"
        }
    }
}

enum SleepQualityRating {
    case excellent, good, fair, poor, tooShort
}

struct SoundEvent: Identifiable {
    let id = UUID()
    let type: SoundEventType
    let timestamp: Date
    let duration: TimeInterval
    let intensity: Double
    let waveformData: [Float]
}

enum SoundEventType: String, CaseIterable {
    case snoring = "Snoring"
    case talking = "Talking"
    case movement = "Movement"
    case other = "Other"
    
    var emoji: String {
        switch self {
        case .snoring: return "😴"
        case .talking: return "💬"
        case .movement: return "🏃"
        case .other: return "🔊"
        }
    }
}

struct NoiseReading: Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: Double // in dB
}
