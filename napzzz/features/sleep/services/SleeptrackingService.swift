//
//  SleeptrackingService.swift
//  napzzz
//
//  Created by Morris Romagnoli on 07/07/2025.
//

import Foundation
import Combine

class SleepTrackingService: ObservableObject {
    static let shared = SleepTrackingService()
    
    @Published var isTracking = false
    @Published var currentSession: SleepSessionData?
    
    private var sessionStartTime: Date?
    private var sleepPhases: [SleepPhaseData] = []
    private var detectedSounds: [SoundEvent] = []
    private var noiseReadings: [NoiseReading] = []
    private var timer: Timer?
    
    private init() {}
    
    func startSleepTracking() {
        sessionStartTime = Date()
        isTracking = true
        sleepPhases.removeAll()
        detectedSounds.removeAll()
        noiseReadings.removeAll()
        
        // Start monitoring
        startPhaseTracking()
        startNoiseMonitoring()
        startSoundDetection()
        
        print("🌙 Sleep tracking started at \(sessionStartTime!)")
    }
    
    func endSleepTracking() {
        guard let startTime = sessionStartTime else { return }
        
        isTracking = false
        timer?.invalidate()
        
        let endTime = Date()
        
        // Calculate sleep phases percentages
        let totalSleepTime = endTime.timeIntervalSince(startTime)
        for i in 0..<sleepPhases.count {
            sleepPhases[i].percentage = (sleepPhases[i].duration / totalSleepTime) * 100
        }
        
        // Calculate sleep quality
        let sleepQuality = calculateSleepQuality(
            totalTime: totalSleepTime,
            phases: sleepPhases,
            sounds: detectedSounds
        )
        
        // Create session data
        currentSession = SleepSessionData(
            date: startTime,
            startTime: startTime,
            endTime: endTime,
            sleepPhases: sleepPhases,
            detectedSounds: detectedSounds,
            ambientNoise: noiseReadings,
            sleepQuality: sleepQuality,
            sleepGoal: 8 * 3600 // 8 hours
        )
        
        print("🌅 Sleep tracking ended. Session created with quality score: \(sleepQuality.score)")
        
        // Save to insights
        InsightsDataManager.shared.addSleepSession(currentSession!)
    }
    
    private func startPhaseTracking() {
        // Simulate sleep phase detection
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.simulateSleepPhaseDetection()
        }
    }
    
    private func startNoiseMonitoring() {
        // Simulate ambient noise monitoring
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            if self.isTracking {
                let noiseLevel = Double.random(in: 20...45) // dB
                let reading = NoiseReading(timestamp: Date(), level: noiseLevel)
                self.noiseReadings.append(reading)
            }
        }
    }
    
    private func startSoundDetection() {
        // Simulate sound event detection
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            if self.isTracking && Double.random(in: 0...1) < 0.3 { // 30% chance
                self.simulateSoundEvent()
            }
        }
    }
    
    private func simulateSleepPhaseDetection() {
        guard let startTime = sessionStartTime else { return }
        
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(startTime)
        
        // Determine current sleep phase based on elapsed time
        let phaseType: SleepPhaseType
        let phaseDuration: TimeInterval = 30 * 60 // 30 minutes
        
        switch Int(elapsedTime / phaseDuration) % 4 {
        case 0:
            phaseType = .light
        case 1:
            phaseType = .deep
        case 2:
            phaseType = .rem
        default:
            phaseType = .light
        }
        
        // Add initial awake phase if this is the first phase
        if sleepPhases.isEmpty {
            let awakePhase = SleepPhaseData(
                type: .awake,
                startTime: startTime,
                duration: TimeInterval.random(in: 300...900) // 5-15 minutes
            )
            sleepPhases.append(awakePhase)
        }
        
        let phase = SleepPhaseData(
            type: phaseType,
            startTime: currentTime,
            duration: phaseDuration
        )
        sleepPhases.append(phase)
    }
    
    private func simulateSoundEvent() {
        let eventTypes = SoundEventType.allCases
        let eventType = eventTypes.randomElement() ?? .other
        
        let waveform = generateWaveformData(for: eventType)
        
        let event = SoundEvent(
            type: eventType,
            timestamp: Date(),
            duration: TimeInterval.random(in: 5...30),
            intensity: Double.random(in: 0.3...1.0),
            waveformData: waveform
        )
        
        detectedSounds.append(event)
    }
    
    private func generateWaveformData(for type: SoundEventType) -> [Float] {
        let sampleCount = 100
        var waveform: [Float] = []
        
        for i in 0..<sampleCount {
            let amplitude: Float
            switch type {
            case .snoring:
                amplitude = Float(sin(Double(i) * 0.1)) * Float.random(in: 0.3...0.8)
            case .talking:
                amplitude = Float.random(in: -0.6...0.6)
            case .movement:
                amplitude = Float.random(in: -0.4...0.4) * (i < 20 ? 1.0 : 0.2)
            case .other:
                amplitude = Float.random(in: -0.3...0.3)
            }
            waveform.append(amplitude)
        }
        
        return waveform
    }
    
    private func calculateSleepQuality(
        totalTime: TimeInterval,
        phases: [SleepPhaseData],
        sounds: [SoundEvent]
    ) -> SleepQualityScore {
        let hours = totalTime / 3600
        
        // Base score on sleep duration
        var score = 0
        let rating: SleepQualityRating
        
        if hours < 4 {
            score = Int.random(in: 10...30)
            rating = .tooShort
        } else if hours < 6 {
            score = Int.random(in: 30...50)
            rating = .poor
        } else if hours < 7 {
            score = Int.random(in: 50...70)
            rating = .fair
        } else if hours < 9 {
            score = Int.random(in: 70...90)
            rating = .good
        } else {
            score = Int.random(in: 85...95)
            rating = .excellent
        }
        
        // Adjust for sound disruptions
        let soundPenalty = min(sounds.count * 5, 20)
        score = max(0, score - soundPenalty)
        
        return SleepQualityScore(score: score, rating: rating)
    }
}
