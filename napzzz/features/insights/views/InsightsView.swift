//
//  InsightsView.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with date
                    InsightsHeaderSection(selectedDate: viewModel.selectedDate)
                    
                    // Day Selector
                    DaySelectorSection(
                        weeklyData: viewModel.weeklyData,
                        selectedDate: viewModel.selectedDate,
                        onDateSelected: { date in
                            viewModel.selectDate(date)
                        }
                    )
                    
                    if let sleepData = viewModel.currentSleepData {
                        VStack(spacing: 20) {
                            // Sleep Quality Section
                            SleepQualitySection(
                                sleepData: sleepData,
                                showingQuality: viewModel.showingSleepQuality
                            ) {
                                viewModel.unlockSleepQuality()
                            }
                            
                            // Sleep Times Section
                            SleepTimesSection(sleepData: sleepData, viewModel: viewModel)
                            
                            // Sleep Goal Progress
                            SleepGoalSection(sleepData: sleepData, viewModel: viewModel)
                            
                            // Sleep Phases Section with Graph
                            SleepPhasesGraphSection(sleepData: sleepData, viewModel: viewModel)
                            
                            // Detected Sounds Section
                            if !sleepData.detectedSounds.isEmpty {
                                DetectedSoundsSection(sleepData: sleepData, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    } else {
                        NoDataView()
                    }
                }
            }
            .background(Color.defaultBackground)
            .navigationBarHidden(true)
        }
    }
}

struct InsightsHeaderSection: View {
    let selectedDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(selectedDate))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "info.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM d"
        return formatter.string(from: date)
    }
}

struct DaySelectorSection: View {
    let weeklyData: [SleepData]
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(weeklyData, id: \.id) { sleepData in
                    DayButton(
                        sleepData: sleepData,
                        isSelected: Calendar.current.isDate(sleepData.date, inSameDayAs: selectedDate),
                        onTap: {
                            onDateSelected(sleepData.date)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 25)
    }
}

struct DayButton: View {
    let sleepData: SleepData
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(dayNumber(sleepData.date))
                    .font(.title2)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : .gray)
                
                Text(dayName(sleepData.date))
                    .font(.caption)
                    .foregroundColor(isSelected ? .defaultAccent : .gray)
                
                // Sleep quality indicator
                Circle()
                    .fill(Color(sleepData.sleepQuality.color))
                    .frame(width: 8, height: 8)
                    .opacity(isSelected ? 1.0 : 0.6)
            }
            .frame(width: 50)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.defaultCardBackground : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.defaultAccent : Color.clear, lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func dayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

struct SleepQualitySection: View {
    let sleepData: SleepData
    let showingQuality: Bool
    let onUnlock: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Quality Circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: showingQuality ? sleepData.sleepQuality.score : 0)
                    .stroke(
                        LinearGradient(
                            colors: [Color.defaultPrimary, Color.defaultAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: showingQuality)
                
                VStack(spacing: 8) {
                    if showingQuality {
                        Text(sleepData.sleepQuality.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Sleep Quality")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Button(action: onUnlock) {
                            VStack(spacing: 8) {
                                Text("Unlock")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.defaultPrimary, Color.defaultAccent],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(20)
                                
                                Text("to see Sleep Quality")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SleepTimesSection: View {
    let sleepData: SleepData
    let viewModel: InsightsViewModel
    
    var body: some View {
        HStack(spacing: 40) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.defaultSecondary)
                    Text(viewModel.formatTime(sleepData.bedtime))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.defaultAccent)
                    Text(viewModel.formatTime(sleepData.wakeTime))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.vertical, 20)
    }
}

struct SleepGoalSection: View {
    let sleepData: SleepData
    let viewModel: InsightsViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(viewModel.formatDuration(sleepData.actualSleepTime))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if sleepData.actualSleepTime < sleepData.sleepGoal {
                            Image(systemName: "triangle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text("Time asleep")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(viewModel.formatDuration(sleepData.sleepGoal))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text("Sleep Goal")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if sleepData.actualSleepTime < sleepData.sleepGoal {
                Text("You're \(viewModel.formatDuration(sleepData.timeAwayFromGoal)) away from reaching your sleep goal")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.defaultCardBackground)
        .cornerRadius(16)
    }
}

struct SleepPhasesGraphSection: View {
    let sleepData: SleepData
    let viewModel: InsightsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Sleep Phases")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
            }
            
            // Sleep phases visualization with graph
            SleepPhasesGraph(sleepData: sleepData, viewModel: viewModel)
            
            // Phase breakdown
            SleepPhaseBreakdown(sleepData: sleepData, viewModel: viewModel)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.defaultCardBackground)
        .cornerRadius(16)
    }
}

struct SleepPhasesGraph: View {
    let sleepData: SleepData
    let viewModel: InsightsViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Phase labels
            HStack {
                ForEach(SleepPhaseType.allCases, id: \.self) { phase in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(phase.color))
                            .frame(width: 8, height: 8)
                        Text(phase.displayName)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Main sleep graph
            GeometryReader { geometry in
                let totalDuration = sleepData.totalSleepTime
                let width = geometry.size.width
                
                HStack(spacing: 0) {
                    ForEach(sleepData.sleepPhases) { phase in
                        let phaseWidth = width * (phase.duration / totalDuration)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(phase.type.color),
                                        Color(phase.type.color).opacity(0.7)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: phaseWidth)
                    }
                }
                .frame(height: 60)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .frame(height: 60)
            
            // Time markers
            HStack {
                Text(viewModel.formatTime(sleepData.bedtime))
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Middle time marker
                let middleTime = sleepData.bedtime.addingTimeInterval(sleepData.totalSleepTime / 2)
                Text(viewModel.formatTime(middleTime))
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(viewModel.formatTime(sleepData.wakeTime))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct SleepPhaseBreakdown: View {
    let sleepData: SleepData
    let viewModel: InsightsViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(SleepPhaseType.allCases, id: \.self) { phaseType in
                if let phase = sleepData.sleepPhases.first(where: { $0.type == phaseType }) {
                    HStack {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(phaseType.color))
                                .frame(width: 12, height: 12)
                            
                            Text(viewModel.formatDuration(phase.duration))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text(phaseType.displayName)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct DetectedSoundsSection: View {
    let sleepData: SleepData
    let viewModel: InsightsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Detected Sounds")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(sleepData.detectedSounds) { sound in
                    DetectedSoundRow(sound: sound, viewModel: viewModel)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.defaultCardBackground)
        .cornerRadius(16)
    }
}

struct DetectedSoundRow: View {
    let sound: DetectedSound
    let viewModel: InsightsViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            Text(sound.type.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(sound.type.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Intensity visualization
                HStack(spacing: 2) {
                    ForEach(0..<10, id: \.self) { index in
                        Rectangle()
                            .fill(Double(index) / 10.0 <= sound.intensity ? Color.defaultAccent : Color.gray.opacity(0.3))
                            .frame(width: 3, height: 12)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(viewModel.formatTime(sound.timestamp))
                    .font(.caption)
                    .foregroundColor(.white)
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            Button(action: {}) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 8)
    }
}

struct NoDataView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 60))
                .foregroundColor(.defaultSecondary)
            
            Text("No Sleep Data")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Start tracking your sleep to see insights")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }
}

#Preview {
    InsightsView()
        .preferredColorScheme(.dark)
}
