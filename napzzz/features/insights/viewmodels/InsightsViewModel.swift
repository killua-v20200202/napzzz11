//
//  InsightsViewModel.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import Foundation
import Combine

class InsightsViewModel: ObservableObject {
    @Published var currentSleepData: SleepData?
    @Published var weeklyData: [SleepData] = []
    @Published var selectedDate: Date = Date()
    @Published var showingSleepQuality: Bool = false
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        // Create sample sleep data for the last 7 days
        var sampleData: [SleepData] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let bedtime = calendar.date(bySettingHour: 23, minute: Int.random(in: 0...59), second: 0, of: date) ?? date
            let wakeTime = calendar.date(byAdding: .hour, value: Int.random(in: 6...9), to: bedtime) ?? date
            
            let sleepPhases = generateSampleSleepPhases(bedtime: bedtime, wakeTime: wakeTime)
            let detectedSounds = generateSampleDetectedSounds(bedtime: bedtime, wakeTime: wakeTime)
            
            let sleepData = SleepData(
                date: date,
                bedtime: bedtime,
                wakeTime: wakeTime,
                sleepQuality: SleepQuality.allCases.randomElement() ?? .good,
                sleepPhases: sleepPhases,
                detectedSounds: detectedSounds,
                sleepGoal: 8 * 3600, // 8 hours in seconds
                actualSleepTime: TimeInterval(Int.random(in: 5...9) * 3600) // 5-9 hours
            )
            
            sampleData.append(sleepData)
        }
        
        weeklyData = sampleData.sorted { $0.date > $1.date }
        currentSleepData = weeklyData.first
    }
    
    private func generateSampleSleepPhases(bedtime: Date, wakeTime: Date) -> [SleepPhase] {
        var phases: [SleepPhase] = []
        let totalDuration = wakeTime.timeIntervalSince(bedtime)
        var currentTime = bedtime
        
        // Awake phase (initial)
        let awakeDuration = TimeInterval.random(in: 300...1800) // 5-30 minutes
        phases.append(SleepPhase(type: .awake, startTime: currentTime, duration: awakeDuration))
        currentTime = currentTime.addingTimeInterval(awakeDuration)
        
        // Light sleep
        let lightDuration = totalDuration * 0.3
        phases.append(SleepPhase(type: .light, startTime: currentTime, duration: lightDuration))
        currentTime = currentTime.addingTimeInterval(lightDuration)
        
        // Deep sleep
        let deepDuration = totalDuration * 0.4
        phases.append(SleepPhase(type: .deep, startTime: currentTime, duration: deepDuration))
        currentTime = currentTime.addingTimeInterval(deepDuration)
        
        // REM sleep
        let remDuration = totalDuration * 0.25
        phases.append(SleepPhase(type: .rem, startTime: currentTime, duration: remDuration))
        
        return phases
    }
    
    private func generateSampleDetectedSounds(bedtime: Date, wakeTime: Date) -> [DetectedSound] {
        var sounds: [DetectedSound] = []
        let totalDuration = wakeTime.timeIntervalSince(bedtime)
        
        // Generate 2-5 random sound events
        let soundCount = Int.random(in: 2...5)
        
        for _ in 0..<soundCount {
            let randomOffset = TimeInterval.random(in: 0...totalDuration)
            let timestamp = bedtime.addingTimeInterval(randomOffset)
            let soundType = SoundType.allCases.randomElement() ?? .snoring
            
            let sound = DetectedSound(
                type: soundType,
                timestamp: timestamp,
                intensity: Double.random(in: 0.3...1.0),
                duration: TimeInterval.random(in: 30...300) // 30 seconds to 5 minutes
            )
            
            sounds.append(sound)
        }
        
        return sounds.sorted { $0.timestamp < $1.timestamp }
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
        currentSleepData = weeklyData.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func unlockSleepQuality() {
        showingSleepQuality = true
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours) h \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
}
