//
//  SleepTrackerViewModel.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import Foundation
import SwiftUI
import Combine

class SleepTrackerViewModel: ObservableObject {
    @Published var sleepSchedule: SleepSchedule
    @Published var selectedActivities: Set<SleepActivity> = []
    @Published var selectedAlarmTone: AlarmTone = .gentle
    @Published var isTrackingSleep = false
    @Published var showingBedtimeEditor = false
    @Published var showingAlarmEditor = false
    @Published var showingPreSleepActivities = false
    @Published var showingSleepSession = false
    @Published var currentStep: SleepFlowStep = .schedule
    
    // Circular time picker state
    @Published var isDraggingBedtime = false
    @Published var isDraggingWakeTime = false
    
    private let audioManager = AudioManager.shared
    private let sleepTrackingService = SleepTrackingService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum SleepFlowStep {
        case schedule
        case preSleepActivities
        case sleepSession
    }
    
    init() {
        // Initialize with default sleep schedule (11 PM to 7 AM)
        let calendar = Calendar.current
        let now = Date()
        
        let bedtime = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: now) ?? now
        let wakeTime = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: now) ?? now) ?? now
        
        self.sleepSchedule = SleepSchedule(bedtime: bedtime, wakeTime: wakeTime)
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind sleep tracking service state
        sleepTrackingService.$isTracking
            .assign(to: \.isTrackingSleep, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Time Picker Functions
    
    func updateBedtime(from angle: Double) {
        let normalizedAngle = angle < 0 ? angle + 360 : angle
        let hour = Int((normalizedAngle / 15).rounded()) % 24
        let calendar = Calendar.current
        
        // Create new bedtime with the selected hour
        var newBedtime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: sleepSchedule.bedtime) ?? sleepSchedule.bedtime
        
        // Keep the wake time FIXED - only adjust bedtime
        // If bedtime would be after wake time on the same day, move bedtime to previous day
        let wakeTimeComponents = calendar.dateComponents([.hour, .minute], from: sleepSchedule.wakeTime)
        let bedtimeComponents = calendar.dateComponents([.hour, .minute], from: newBedtime)
        
        if let bedHour = bedtimeComponents.hour, let wakeHour = wakeTimeComponents.hour {
            if bedHour < wakeHour {
                // Bedtime is in the morning, should be previous day
                newBedtime = calendar.date(byAdding: .day, value: -1, to: newBedtime) ?? newBedtime
            }
        }
        
        sleepSchedule.bedtime = newBedtime
        // Wake time stays unchanged
    }
    
    func updateWakeTime(from angle: Double) {
        let normalizedAngle = angle < 0 ? angle + 360 : angle
        let hour = Int((normalizedAngle / 15).rounded()) % 24
        let calendar = Calendar.current
        
        // Create new wake time with the selected hour
        var newWakeTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: sleepSchedule.wakeTime) ?? sleepSchedule.wakeTime
        
        // Keep the bedtime FIXED - only adjust wake time
        // If wake time would be before bedtime on the same day, move wake time to next day
        let bedtimeComponents = calendar.dateComponents([.hour, .minute], from: sleepSchedule.bedtime)
        let wakeTimeComponents = calendar.dateComponents([.hour, .minute], from: newWakeTime)
        
        if let bedHour = bedtimeComponents.hour, let wakeHour = wakeTimeComponents.hour {
            if wakeHour <= bedHour {
                // Wake time is same day or before bedtime, should be next day
                newWakeTime = calendar.date(byAdding: .day, value: 1, to: newWakeTime) ?? newWakeTime
            }
        }
        
        sleepSchedule.wakeTime = newWakeTime
        // Bedtime stays unchanged
    }
    
    func angleForTime(_ date: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        // Convert to 24-hour format with minutes precision
        let totalMinutes = hour * 60 + minute
        let angle = Double(totalMinutes) * 360.0 / (24.0 * 60.0)
        
        return angle
    }
    
    // MARK: - Sleep Flow Functions
    
    func startSleepFlow() {
        currentStep = .preSleepActivities
        showingPreSleepActivities = true
    }
    
    func proceedToSleepSession() {
        currentStep = .sleepSession
        showingPreSleepActivities = false
        showingSleepSession = true
        
        // Start sleep tracking
        sleepTrackingService.startSleepTracking()
    }
    
    func skipPreSleepActivities() {
        selectedActivities.removeAll()
        proceedToSleepSession()
    }
    
    func endSleepSession() {
        // End sleep tracking
        sleepTrackingService.endSleepTracking()
        
        showingSleepSession = false
        currentStep = .schedule
        audioManager.stopAllSounds()
        
        // Show insights with new data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // This could trigger a notification or navigation to insights
            NotificationCenter.default.post(name: .sleepSessionCompleted, object: nil)
        }
    }
    
    // MARK: - Activity Management
    
    func toggleActivity(_ activity: SleepActivity) {
        if selectedActivities.contains(activity) {
            selectedActivities.remove(activity)
        } else {
            selectedActivities.insert(activity)
        }
    }
    
    func isActivitySelected(_ activity: SleepActivity) -> Bool {
        return selectedActivities.contains(activity)
    }
    
    // MARK: - Time Formatting
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func formatTimeRange() -> String {
        return "\(formatTime(sleepSchedule.bedtime)) - \(formatTime(sleepSchedule.wakeTime))"
    }
    
    // MARK: - Alarm Functions
    
    func setAlarmTone(_ tone: AlarmTone) {
        selectedAlarmTone = tone
    }
    
    func previewAlarmTone(_ tone: AlarmTone) {
        // Preview alarm tone functionality
        print("Previewing alarm tone: \(tone.rawValue)")
    }
}

extension Notification.Name {
    static let sleepSessionCompleted = Notification.Name("sleepSessionCompleted")
}
