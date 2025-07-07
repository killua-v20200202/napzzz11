//
//  InsightsDataManager.swift
//  napzzz
//
//  Created by Morris Romagnoli on 07/07/2025.
//

import Foundation
import Combine

class InsightsDataManager: ObservableObject {
    static let shared = InsightsDataManager()
    
    @Published var sleepSessions: [SleepSessionData] = []
    @Published var latestSession: SleepSessionData?
    
    private init() {
        loadSampleData()
    }
    
    func addSleepSession(_ session: SleepSessionData) {
        sleepSessions.insert(session, at: 0) // Add to beginning
        latestSession = session
        
        // Keep only last 30 sessions
        if sleepSessions.count > 30 {
            sleepSessions = Array(sleepSessions.prefix(30))
        }
        
        print("📊 Sleep session added to insights. Total sessions: \(sleepSessions.count)")
    }
    
    func getSessionsForWeek(from date: Date) -> [SleepSessionData] {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? date
        
        return sleepSessions.filter { session in
            session.date >= weekStart && session.date < weekEnd
        }
    }
    
    func getSessionForDate(_ date: Date) -> SleepSessionData? {
        let calendar = Calendar.current
        return sleepSessions.first { session in
            calendar.isDate(session.date, inSameDayAs: date)
        }
    }
    
    private func loadSampleData() {
        // Create some sample data for demonstration
        let calendar = Calendar.current
        let today = Date()
        
        for i in 1...7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let startTime = calendar.date(bySettingHour: 23, minute: Int.random(in: 0...59), second: 0, of: date) ?? date
            let endTime = calendar.date(byAdding: .hour, value: Int.random(in: 6...9), to: startTime) ?? date
            
            let session = createSampleSession(date: date, startTime: startTime, endTime: endTime)
            sleepSessions.append(session)
        }
        
        sleepSessions.sort { $0.date > $1.date }
        latestSession = sleepSessions.first
    }
    
    private func createSampleSession(date: Date, startTime: Date, endTime: Date) -> SleepSessionData {
        let totalDuration = endTime.timeIntervalSince(startTime)
        
        // Create sample sleep phases
        var phases: [SleepPhaseData] = []
        var currentTime = startTime
        
        // Awake phase
        let awakeDuration = TimeInterval.random(in: 300...1200)
        phases.append(SleepPhaseData(
            type: .awake,
            startTime: currentTime,
            duration: awakeDuration,
            percentage: (awakeDuration / totalDuration) * 100
        ))
        currentTime = currentTime.addingTimeInterval(awakeDuration)
        
        // Light sleep
        let lightDuration = totalDuration * 0.45
        phases.append(SleepPhaseData(
            type: .light,
            startTime: currentTime,
            duration: lightDuration,
            percentage: 45
        ))
        currentTime = currentTime.addingTimeInterval(lightDuration)
        
        // Deep sleep
        let deepDuration = totalDuration * 0.25
        phases.append(SleepPhaseData(
            type: .deep,
            startTime: currentTime,
            duration: deepDuration,
            percentage: 25
        ))
        currentTime = currentTime.addingTimeInterval(deepDuration)
        
        // REM sleep
        let remDuration = totalDuration * 0.20
        phases.append(SleepPhaseData(
            type: .rem,
            startTime: currentTime,
            duration: remDuration,
            percentage: 20
        ))
        
        // Sample sound events
        let soundEvents = createSampleSoundEvents(startTime: startTime, endTime: endTime)
        
        // Sample noise readings
        let noiseReadings = createSampleNoiseReadings(startTime: startTime, endTime: endTime)
        
        // Calculate quality
        let hours = totalDuration / 3600
        let score = Int.random(in: 60...95)
        let rating: SleepQualityRating = hours < 6 ? .poor : (hours < 7 ? .fair : (hours < 8 ? .good : .excellent))
        let quality = SleepQualityScore(score: score, rating: rating)
        
        return SleepSessionData(
            date: date,
            startTime: startTime,
            endTime: endTime,
            sleepPhases: phases,
            detectedSounds: soundEvents,
            ambientNoise: noiseReadings,
            sleepQuality: quality,
            sleepGoal: 8 * 3600
        )
    }
    
    private func createSampleSoundEvents(startTime: Date, endTime: Date) -> [SoundEvent] {
        let eventCount = Int.random(in: 2...8)
        var events: [SoundEvent] = []
        
        for _ in 0..<eventCount {
            let randomTime = Date(timeInterval: TimeInterval.random(in: 0...endTime.timeIntervalSince(startTime)), since: startTime)
            let eventType = SoundEventType.allCases.randomElement() ?? .other
            
            let waveform = (0..<100).map { i in
                Float(sin(Double(i) * 0.1)) * Float.random(in: 0.2...0.8)
            }
            
            let event = SoundEvent(
                type: eventType,
                timestamp: randomTime,
                duration: TimeInterval.random(in: 5...60),
                intensity: Double.random(in: 0.3...1.0),
                waveformData: waveform
            )
            events.append(event)
        }
        
        return events.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func createSampleNoiseReadings(startTime: Date, endTime: Date) -> [NoiseReading] {
        var readings: [NoiseReading] = []
        let interval: TimeInterval = 300 // Every 5 minutes
        
        var currentTime = startTime
        while currentTime < endTime {
            let reading = NoiseReading(
                timestamp: currentTime,
                level: Double.random(in: 20...40)
            )
            readings.append(reading)
            currentTime = currentTime.addingTimeInterval(interval)
        }
        
        return readings
    }
}
