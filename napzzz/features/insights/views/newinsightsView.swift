//
//  newinsightsView.swift
//  napzzz
//
//  Created by Morris Romagnoli on 07/07/2025.
//

import SwiftUI

struct NewInsightsView: View {
    @StateObject private var dataManager = InsightsDataManager.shared
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    InsightsHeaderSection(selectedDate: selectedDate)
                    
                    // Day Selector
                    DaySelectorSection(
                        sessions: dataManager.sleepSessions,
                        selectedDate: selectedDate,
                        onDateSelected: { date in
                            selectedDate = date
                        }
                    )
                    
                    if let session = dataManager.getSessionForDate(selectedDate) {
                        VStack(spacing: 20) {
                            // Sleep Quality Card
                            SleepQualityCard(session: session)
                            
                            // Sleep Times Card
                            SleepTimesCard(session: session)
                            
                            // Sleep Phases Graph Card - MODIFIED SECTION
                            SleepPhasesGraphCard(session: session)
                            
                            // Sound Events Card
                            if !session.detectedSounds.isEmpty {
                                SoundEventsCard(session: session)
                            }
                            
                            // Noise Level Card
                            NoiseLevelCard(session: session)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    } else {
                        NoSleepDataView()
                    }
                }
            }
            .background(Color.defaultBackground)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Header Section
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

// MARK: - Day Selector Section
struct DaySelectorSection: View {
    let sessions: [SleepSessionData]
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(sessions, id: \.id) { session in
                    DayButton(
                        session: session,
                        isSelected: Calendar.current.isDate(session.date, inSameDayAs: selectedDate),
                        onTap: {
                            onDateSelected(session.date)
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
    let session: SleepSessionData
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(dayNumber(session.date))
                    .font(.title2)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : .gray)
                
                Text(dayName(session.date))
                    .font(.caption)
                    .foregroundColor(isSelected ? .defaultAccent : .gray)
                
                // Sleep quality indicator
                Circle()
                    .fill(Color(session.sleepQuality.color))
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

// MARK: - Sleep Quality Card
struct SleepQualityCard: View {
    let session: SleepSessionData
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Sleep Quality")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
            }
            
            // Quality Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: Double(session.sleepQuality.score) / 100.0)
                    .stroke(
                        LinearGradient(
                            colors: [Color.defaultPrimary, Color.defaultAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(session.sleepQuality.score)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(session.sleepQuality.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.defaultCardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Sleep Times Card
struct SleepTimesCard: View {
    let session: SleepSessionData
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Sleep Times")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.defaultSecondary)
                        Text(formatTime(session.startTime))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    Text("Bedtime")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.defaultAccent)
                        Text(formatTime(session.endTime))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    Text("Wake Up")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(spacing: 8) {
                Text(formatDuration(session.totalSleepTime))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Total Sleep Time")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.defaultCardBackground)
        .cornerRadius(16)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Sleep Phases Graph Card - MODIFIED SECTION
struct SleepPhasesGraphCard: View {
    let session: SleepSessionData
    
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
            
            // Smooth Sleep Graph with Phase Indicators
            SmoothSleepGraph(session: session)
            
            // Time markers
            HStack {
                Text(formatTime(session.startTime))
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                let middleTime = session.startTime.addingTimeInterval(session.totalSleepTime / 2)
                Text(formatTime(middleTime))
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(formatTime(session.endTime))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 80) // Account for right side indicators
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.defaultCardBackground)
        .cornerRadius(16)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Smooth Sleep Graph - NEW COMPONENT
struct SmoothSleepGraph: View {
    let session: SleepSessionData
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Main graph area (75% width)
                ZStack {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 120)
                        .cornerRadius(8)
                    
                    // Smooth sleep curve
                    SmoothSleepCurve(
                        sleepPhases: session.sleepPhases,
                        totalDuration: session.totalSleepTime,
                        graphWidth: geometry.size.width * 0.75,
                        graphHeight: 120
                    )
                }
                .frame(width: geometry.size.width * 0.75)
                
                // Right side phase indicators (25% width)
                VStack(spacing: 12) {
                    SleepPhaseIndicator(
                        phase: .awake,
                        isCurrentPhase: getCurrentPhase() == .awake,
                        currentHour: getCurrentHour()
                    )
                    
                    SleepPhaseIndicator(
                        phase: .light,
                        isCurrentPhase: getCurrentPhase() == .light,
                        currentHour: getCurrentHour()
                    )
                    
                    SleepPhaseIndicator(
                        phase: .deep,
                        isCurrentPhase: getCurrentPhase() == .deep,
                        currentHour: getCurrentHour()
                    )
                }
                .frame(width: geometry.size.width * 0.25)
                .padding(.leading, 10)
            }
        }
        .frame(height: 120)
    }
    
    private func getCurrentPhase() -> SleepPhaseType {
        // Get the most recent phase or simulate current phase
        return session.sleepPhases.last?.type ?? .light
    }
    
    private func getCurrentHour() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

// MARK: - Smooth Sleep Curve - NEW COMPONENT
struct SmoothSleepCurve: View {
    let sleepPhases: [SleepPhaseData]
    let totalDuration: TimeInterval
    let graphWidth: CGFloat
    let graphHeight: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let path = createSmoothSleepPath()
            
            // Fill area under curve with gradient
            var fillPath = path
            fillPath.addLine(to: CGPoint(x: graphWidth, y: graphHeight))
            fillPath.addLine(to: CGPoint(x: 0, y: graphHeight))
            fillPath.closeSubpath()
            
            context.fill(fillPath, with: .linearGradient(
                Gradient(colors: [
                    Color.blue.opacity(0.4),
                    Color.purple.opacity(0.3),
                    Color.blue.opacity(0.1),
                    Color.clear
                ]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: graphHeight)
            ))
            
            // Draw smooth curve line
            context.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        }
        .frame(width: graphWidth, height: graphHeight)
    }
    
    private func createSmoothSleepPath() -> Path {
        var path = Path()
        
        // Convert sleep phases to data points
        var dataPoints: [(x: CGFloat, y: CGFloat)] = []
        var currentTime: TimeInterval = 0
        
        for phase in sleepPhases {
            let x = CGFloat(currentTime / totalDuration) * graphWidth
            let y = yPositionForPhase(phase.type)
            dataPoints.append((x: x, y: y))
            
            currentTime += phase.duration
            let endX = CGFloat(currentTime / totalDuration) * graphWidth
            dataPoints.append((x: endX, y: y))
        }
        
        // Create smooth curve through points
        if !dataPoints.isEmpty {
            path.move(to: CGPoint(x: dataPoints[0].x, y: dataPoints[0].y))
            
            for i in 1..<dataPoints.count {
                let current = dataPoints[i]
                let previous = dataPoints[i-1]
                
                // Create smooth curve using quadratic bezier
                let controlPointX = (previous.x + current.x) / 2
                let controlPointY = (previous.y + current.y) / 2
                
                path.addQuadCurve(
                    to: CGPoint(x: current.x, y: current.y),
                    control: CGPoint(x: controlPointX, y: controlPointY)
                )
            }
        }
        
        return path
    }
    
    private func yPositionForPhase(_ phase: SleepPhaseType) -> CGFloat {
        switch phase {
        case .awake:
            return 20 // Top of graph
        case .light:
            return 60 // Middle
        case .deep:
            return 100 // Bottom
        case .rem:
            return 40 // Between light and awake
        }
    }
}

// MARK: - Sleep Phase Indicator - NEW COMPONENT
struct SleepPhaseIndicator: View {
    let phase: SleepPhaseType
    let isCurrentPhase: Bool
    let currentHour: String
    
    var body: some View {
        HStack(spacing: 8) {
            // Phase color indicator
            Circle()
                .fill(Color(phase.color))
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isCurrentPhase ? 2 : 0)
                        .frame(width: 16, height: 16)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(phase.displayName)
                    .font(.caption)
                    .fontWeight(isCurrentPhase ? .semibold : .medium)
                    .foregroundColor(isCurrentPhase ? .white : .gray)
                
                if isCurrentPhase {
                    Text(currentHour)
                        .font(.caption2)
                        .foregroundColor(.defaultAccent)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isCurrentPhase ? Color.defaultAccent.opacity(0.2) : Color.clear)
        )
        .scaleEffect(isCurrentPhase ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCurrentPhase)
    }
}

// MARK: - Sound Events Card
struct SoundEventsCard: View {
    let session: SleepSessionData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Sound Events")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(session.detectedSounds.count)")
                    .font(.headline)
                    .foregroundColor(.defaultAccent)
            }
            
            VStack(spacing: 12) {
                ForEach(session.detectedSounds.prefix(3)) { sound in
                    SoundEventRow(sound: sound)
                }
                
                if session.detectedSounds.count > 3 {
                    Button(action: {}) {
                        Text("View all \(session.detectedSounds.count) events")
                            .font(.caption)
                            .foregroundColor(.defaultAccent)
                    }
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.defaultCardBackground)
        .cornerRadius(16)
    }
}

struct SoundEventRow: View {
    let sound: SoundEvent
    
    var body: some View {
        HStack(spacing: 15) {
            Text(sound.type.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(sound.type.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(formatTime(sound.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Intensity bars
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    Rectangle()
                        .fill(Double(index) / 5.0 <= sound.intensity ? Color.defaultAccent : Color.gray.opacity(0.3))
                        .frame(width: 3, height: 12)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Noise Level Card
struct NoiseLevelCard: View {
    let session: SleepSessionData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Ambient Noise")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(session.averageNoiseLevel)) dB")
                    .font(.headline)
                    .foregroundColor(.defaultAccent)
            }
            
            // Simple noise level visualization
            HStack(spacing: 4) {
                ForEach(0..<10, id: \.self) { index in
                    Rectangle()
                        .fill(Double(index) * 5 <= session.averageNoiseLevel ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 20)
                }
            }
            
            Text("Average noise level throughout the night")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.defaultCardBackground)
        .cornerRadius(16)
    }
}

// MARK: - No Sleep Data View
struct NoSleepDataView: View {
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
    NewInsightsView()
        .preferredColorScheme(.dark)
}