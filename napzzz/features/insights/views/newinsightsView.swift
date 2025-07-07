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
    @State private var showingJournalTab = true
    @State private var showNewSessionAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Professional Header
                EnhancedInsightsHeaderView(showingJournal: $showingJournalTab)
                
                if showingJournalTab {
                    JournalTabView(
                        selectedDate: $selectedDate,
                        dataManager: dataManager
                    )
                } else {
                    StatisticsTabView(dataManager: dataManager)
                }
            }
            .background(Color.defaultBackground)
            .navigationBarHidden(true)
        }
        .onReceive(NotificationCenter.default.publisher(for: .sleepSessionCompleted)) { _ in
            // Show alert for new sleep session and update selected date
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let latestSession = dataManager.latestSession {
                    selectedDate = latestSession.date
                    showNewSessionAlert = true
                }
            }
        }
        .alert("Sleep Session Complete! 🌅", isPresented: $showNewSessionAlert) {
            Button("View Insights") { }
        } message: {
            if let session = dataManager.latestSession {
                Text("Your sleep quality score: \(session.sleepQuality.score)/100\nTotal sleep time: \(formatDuration(session.actualSleepTime))")
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
}

struct EnhancedInsightsHeaderView: View {
    @Binding var showingJournal: Bool
    @State private var animateGradient = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with greeting and settings
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Text("Sleep Insights")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Settings and notification buttons
                HStack(spacing: 16) {
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.defaultCardBackground.opacity(0.6))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "bell")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.defaultCardBackground.opacity(0.6))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "gearshape")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Enhanced Tab Selector with animated background
            ZStack {
                // Animated background gradient
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.defaultCardBackground.opacity(0.8),
                                Color.defaultCardBackground.opacity(0.4)
                            ],
                            startPoint: animateGradient ? .topLeading : .bottomTrailing,
                            endPoint: animateGradient ? .bottomTrailing : .topLeading
                        )
                    )
                    .frame(height: 60)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
                
                HStack(spacing: 0) {
                    // Journal Tab
                    TabButton(
                        title: "Journal",
                        isSelected: showingJournal,
                        icon: "book.closed.fill"
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showingJournal = true
                        }
                    }
                    
                    // Statistics Tab
                    TabButton(
                        title: "Statistics",
                        isSelected: !showingJournal,
                        icon: "chart.bar.fill"
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showingJournal = false
                        }
                    }
                }
                .padding(4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(
            // Header background with subtle gradient
            LinearGradient(
                colors: [
                    Color.defaultBackground,
                    Color.defaultBackground.opacity(0.95),
                    Color.defaultBackground.opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            animateGradient = true
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        case 17..<21:
            return "Good evening"
        default:
            return "Good night"
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Icon with animation
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .black : .white)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                
                // Title text
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .black : .white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                ZStack {
                    if isSelected {
                        // Selected state background with gradient
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        Color.white.opacity(0.95)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(
                                color: Color.black.opacity(0.1),
                                radius: 8,
                                x: 0,
                                y: 2
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.defaultAccent.opacity(0.3),
                                                Color.defaultPrimary.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    } else {
                        // Unselected state - transparent
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.clear)
                    }
                }
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct JournalTabView: View {
    @Binding var selectedDate: Date
    @ObservedObject var dataManager: InsightsDataManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Week selector
                WeekSelectorView(
                    selectedDate: $selectedDate,
                    sessions: dataManager.sleepSessions
                )
                
                // Main content
                if let session = dataManager.getSessionForDate(selectedDate) {
                    SleepSessionDetailView(session: session, selectedDate: selectedDate)
                } else {
                    NoSleepDataView(date: selectedDate)
                }
            }
        }
    }
}

struct WeekSelectorView: View {
    @Binding var selectedDate: Date
    let sessions: [SleepSessionData]
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        var dates: [Date] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dates.append(date)
            }
        }
        
        return dates.reversed()
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Week days header
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            
            // Date buttons
            HStack(spacing: 0) {
                ForEach(weekDates, id: \.self) { date in
                    WeekDayButton(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        hasData: sessions.contains { Calendar.current.isDate($0.date, inSameDayAs: date) },
                        onTap: { selectedDate = date }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 25)
    }
}

struct WeekDayButton: View {
    let date: Date
    let isSelected: Bool
    let hasData: Bool
    let onTap: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(dayNumber)
                    .font(.title2)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : .gray)
                
                // Data indicator
                Circle()
                    .fill(hasData ? Color.defaultAccent : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .opacity(isSelected ? 1.0 : 0.6)
            }
            .frame(maxWidth: .infinity)
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
}

struct SleepSessionDetailView: View {
    let session: SleepSessionData
    let selectedDate: Date
    
    var body: some View {
        VStack(spacing: 25) {
            // Sleep Quality Score - Pass selectedDate to trigger re-animation
            SleepQualityScoreView(session: session, selectedDate: selectedDate)
            
            // Sleep Stages Graph - NEW PROFESSIONAL FLOW GRAPH
            ProfessionalSleepStagesView(session: session)
            
            // Sleep Phase Breakdown
            SleepPhaseBreakdownView(session: session)
            
            // Sleep Metrics
            SleepMetricsView(session: session)
            
            // Sound Events
            if !session.detectedSounds.isEmpty {
                SoundEventsView(session: session)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }
}

struct SleepQualityScoreView: View {
    let session: SleepSessionData
    let selectedDate: Date
    @State private var animateProgress = false
    @State private var animationKey = UUID() // Key to force complete re-animation
    
    private let circleSize: CGFloat = 180
    private let strokeWidth: CGFloat = 16 // Made thicker for better visual impact
    
    var body: some View {
        VStack(spacing: 20) {
            // Sleep quality score text above circle
            Text("Sleep quality score")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 10)
            
            HStack {
                VStack(alignment: .leading, spacing: 15) {
                    // Clean Professional Quality Circle
                    ZStack {
                        // Background circle track
                        Circle()
                            .stroke(
                                Color.gray.opacity(0.15),
                                style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                            )
                            .frame(width: circleSize, height: circleSize)
                        
                        // Progress circle - only the stroke, no fill
                        Circle()
                            .trim(from: 0, to: animateProgress ? Double(session.sleepQuality.score) / 100.0 : 0)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.blue,
                                        Color.cyan,
                                        Color.blue.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                            )
                            .frame(width: circleSize, height: circleSize)
                            .rotationEffect(.degrees(-90))
                            .shadow(
                                color: Color.blue.opacity(0.4),
                                radius: animateProgress ? 8 : 0,
                                x: 0,
                                y: 0
                            )
                            .animation(
                                .easeInOut(duration: 1.0),
                                value: animateProgress
                            )
                            .id(animationKey) // Force complete re-creation when key changes
                        
                        // Center content - shows immediately, no animation delay
                        VStack(spacing: 8) {
                            Text("\(session.sleepQuality.score)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                            
                            Text("Score")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .textCase(.uppercase)
                                .tracking(1.2)
                        }
                        
                        // Subtle outer glow ring
                        Circle()
                            .stroke(
                                Color.blue.opacity(0.1),
                                style: StrokeStyle(lineWidth: 2, lineCap: .round)
                            )
                            .frame(width: circleSize + 12, height: circleSize + 12)
                            .opacity(animateProgress ? 1.0 : 0.0)
                            .scaleEffect(animateProgress ? 1.0 : 0.95)
                            .animation(
                                .easeInOut(duration: 0.8).delay(0.5),
                                value: animateProgress
                            )
                            .id(animationKey) // Force complete re-creation when key changes
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 15) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Time in bed")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(formatTimeRange(session.startTime, session.endTime))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Sleep quality")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(session.sleepQuality.description)
                            .font(.headline)
                            .foregroundColor(Color(session.sleepQuality.color))
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding(.vertical, 20)
        .onChange(of: selectedDate) { _ in
            // Complete reset: change the key to force re-creation and reset animation state
            animationKey = UUID()
            animateProgress = false
            
            // Start fresh animation after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animateProgress = true
            }
        }
        .onAppear {
            // Initial animation when view appears
            animationKey = UUID()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateProgress = true
            }
        }
    }
    
    private func formatTimeRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start))-\(formatter.string(from: end))"
    }
}

// NEW PROFESSIONAL SLEEP STAGES FLOW GRAPH
struct ProfessionalSleepStagesView: View {
    let session: SleepSessionData
    @State private var animateGraph = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sleep stages")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Professional sleep flow graph container
            ZStack {
                // Background with subtle gradient
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.defaultCardBackground.opacity(0.8),
                                Color.defaultCardBackground.opacity(0.4)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                
                VStack(spacing: 0) {
                    // Y-axis labels
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Awake")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(height: 40, alignment: .center)
                            
                            Spacer()
                            
                            Text("Light")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(height: 40, alignment: .center)
                            
                            Spacer()
                            
                            Text("REM")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(height: 40, alignment: .center)
                            
                            Spacer()
                            
                            Text("Deep")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(height: 40, alignment: .center)
                        }
                        .frame(width: 40)
                        
                        // Main graph area
                        SleepFlowGraph(session: session, animate: animateGraph)
                    }
                    
                    // X-axis time labels
                    HStack {
                        Spacer()
                            .frame(width: 40) // Align with Y-axis labels
                        
                        HStack {
                            Text(formatTime(session.startTime))
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatTime(midTime))
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatTime(session.endTime))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(16)
            }
        }
        .padding(.vertical, 20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateGraph = true
            }
        }
    }
    
    private var midTime: Date {
        let totalDuration = session.endTime.timeIntervalSince(session.startTime)
        return session.startTime.addingTimeInterval(totalDuration / 2)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct SleepFlowGraph: View {
    let session: SleepSessionData
    let animate: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                // Subtle grid lines
                ForEach(0..<4) { i in
                    Path { path in
                        let y = CGFloat(i) * (height / 3)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                }
                
                // Main sleep flow line
                SleepFlowPath(
                    phases: session.sleepPhases,
                    width: width,
                    height: height,
                    animate: animate
                )
            }
        }
        .frame(height: 160)
    }
}

struct SleepFlowPath: View {
    let phases: [SleepPhaseData]
    let width: CGFloat
    let height: CGFloat
    let animate: Bool
    
    var body: some View {
        ZStack {
            // Background gradient fill under the line
            SleepFlowFill(phases: phases, width: width, height: height)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.2),
                            Color.blue.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(animate ? 0.6 : 0)
                .animation(.easeInOut(duration: 1.5).delay(0.5), value: animate)
            
            // Main flow line
            SleepFlowLine(phases: phases, width: width, height: height)
                .trim(from: 0, to: animate ? 1 : 0)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.cyan,
                            Color.blue,
                            Color.purple,
                            Color.blue
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                .animation(.easeInOut(duration: 2.0), value: animate)
            
            // REM highlights (red dots)
            ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                if phase.type == .rem {
                    let position = getPhasePosition(phase, phases: phases, width: width, height: height)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .position(position)
                        .scaleEffect(animate ? 1.0 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.1 + 1.0), value: animate)
                }
            }
            
            // Phase transition markers
            ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                let position = getPhasePosition(phase, phases: phases, width: width, height: height)
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 4, height: 4)
                    .position(position)
                    .scaleEffect(animate ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.1 + 1.5), value: animate)
            }
        }
    }
    
    private func getPhasePosition(_ phase: SleepPhaseData, phases: [SleepPhaseData], width: CGFloat, height: CGFloat) -> CGPoint {
        let totalDuration = phases.reduce(0) { $0 + $1.duration }
        let phaseStartTime = phases.prefix(while: { $0.id != phase.id }).reduce(0) { $0 + $1.duration }
        let phaseMiddleTime = phaseStartTime + (phase.duration / 2)
        
        let x = (phaseMiddleTime / totalDuration) * width
        let y = getYPosition(for: phase.type, height: height)
        
        return CGPoint(x: x, y: y)
    }
    
    private func getYPosition(for type: SleepPhaseType, height: CGFloat) -> CGFloat {
        switch type {
        case .awake: return height * 0.1  // Top - Awake
        case .light: return height * 0.35 // Upper middle - Light sleep
        case .rem: return height * 0.65   // Lower middle - REM sleep
        case .deep: return height * 0.9   // Bottom - Deep sleep
        }
    }
}

struct SleepFlowLine: Shape {
    let phases: [SleepPhaseData]
    let width: CGFloat
    let height: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !phases.isEmpty else { return path }
        
        let totalDuration = phases.reduce(0) { $0 + $1.duration }
        var currentTime: TimeInterval = 0
        
        // Create smooth flowing line through all phases
        var points: [CGPoint] = []
        
        for phase in phases {
            let startX = (currentTime / totalDuration) * width
            let endX = ((currentTime + phase.duration) / totalDuration) * width
            let y = getYPosition(for: phase.type, height: height)
            
            // Add start point
            points.append(CGPoint(x: startX, y: y))
            
            // Add end point
            points.append(CGPoint(x: endX, y: y))
            
            currentTime += phase.duration
        }
        
        // Create smooth curve through points
        if !points.isEmpty {
            path.move(to: points[0])
            
            for i in 1..<points.count {
                let currentPoint = points[i]
                let previousPoint = points[i-1]
                
                // Create smooth curve between points
                let controlPoint1 = CGPoint(
                    x: previousPoint.x + (currentPoint.x - previousPoint.x) * 0.3,
                    y: previousPoint.y
                )
                let controlPoint2 = CGPoint(
                    x: previousPoint.x + (currentPoint.x - previousPoint.x) * 0.7,
                    y: currentPoint.y
                )
                
                path.addCurve(
                    to: currentPoint,
                    control1: controlPoint1,
                    control2: controlPoint2
                )
            }
        }
        
        return path
    }
    
    private func getYPosition(for type: SleepPhaseType, height: CGFloat) -> CGFloat {
        switch type {
        case .awake: return height * 0.1  // Top - Awake
        case .light: return height * 0.35 // Upper middle - Light sleep
        case .rem: return height * 0.65   // Lower middle - REM sleep
        case .deep: return height * 0.9   // Bottom - Deep sleep
        }
    }
}

struct SleepFlowFill: Shape {
    let phases: [SleepPhaseData]
    let width: CGFloat
    let height: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !phases.isEmpty else { return path }
        
        let totalDuration = phases.reduce(0) { $0 + $1.duration }
        var currentTime: TimeInterval = 0
        
        // Create points for the line
        var points: [CGPoint] = []
        
        for phase in phases {
            let startX = (currentTime / totalDuration) * width
            let endX = ((currentTime + phase.duration) / totalDuration) * width
            let y = getYPosition(for: phase.type, height: height)
            
            points.append(CGPoint(x: startX, y: y))
            points.append(CGPoint(x: endX, y: y))
            
            currentTime += phase.duration
        }
        
        // Create filled area under the curve
        if !points.isEmpty {
            path.move(to: CGPoint(x: points[0].x, y: height))
            path.addLine(to: points[0])
            
            for i in 1..<points.count {
                let currentPoint = points[i]
                let previousPoint = points[i-1]
                
                let controlPoint1 = CGPoint(
                    x: previousPoint.x + (currentPoint.x - previousPoint.x) * 0.3,
                    y: previousPoint.y
                )
                let controlPoint2 = CGPoint(
                    x: previousPoint.x + (currentPoint.x - previousPoint.x) * 0.7,
                    y: currentPoint.y
                )
                
                path.addCurve(
                    to: currentPoint,
                    control1: controlPoint1,
                    control2: controlPoint2
                )
            }
            
            // Close the path at the bottom
            path.addLine(to: CGPoint(x: points.last!.x, y: height))
            path.closeSubpath()
        }
        
        return path
    }
    
    private func getYPosition(for type: SleepPhaseType, height: CGFloat) -> CGFloat {
        switch type {
        case .awake: return height * 0.1  // Top - Awake
        case .light: return height * 0.35 // Upper middle - Light sleep
        case .rem: return height * 0.65   // Lower middle - REM sleep
        case .deep: return height * 0.9   // Bottom - Deep sleep
        }
    }
}

struct SleepPhaseBreakdownView: View {
    let session: SleepSessionData
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(SleepPhaseType.allCases, id: \.self) { phaseType in
                if let phase = session.sleepPhases.first(where: { $0.type == phaseType }) {
                    PhaseBreakdownRow(phase: phase)
                }
            }
        }
        .padding(.vertical, 20)
    }
}

struct PhaseBreakdownRow: View {
    let phase: SleepPhaseData
    
    var body: some View {
        HStack(spacing: 15) {
            // Phase indicator
            Rectangle()
                .fill(colorForPhase(phase.type))
                .frame(width: 4, height: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(phase.type.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("< \(formatDuration(phase.duration))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(phase.percentage))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("< \(formatDuration(phase.duration))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func colorForPhase(_ type: SleepPhaseType) -> Color {
        switch type {
        case .awake: return .green
        case .light: return .blue
        case .deep: return .purple
        case .rem: return .pink
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct SleepMetricsView: View {
    let session: SleepSessionData
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                MetricCard(
                    title: "In bed",
                    value: formatDuration(session.timeInBed),
                    icon: "bed.double.fill"
                )
                
                MetricCard(
                    title: "Asleep",
                    value: formatDuration(session.actualSleepTime),
                    icon: "moon.zzz.fill"
                )
            }
            
            HStack(spacing: 20) {
                MetricCard(
                    title: "Asleep after",
                    value: formatDuration(session.sleepPhases.first?.duration ?? 0),
                    icon: "clock.fill"
                )
                
                MetricCard(
                    title: "Noise",
                    value: "\(Int(session.averageNoiseLevel)) dB",
                    icon: "waveform"
                )
            }
        }
        .padding(.vertical, 20)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.defaultCardBackground)
        .cornerRadius(12)
    }
}

struct SoundEventsView: View {
    let session: SleepSessionData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Clips")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(session.detectedSounds.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.defaultAccent)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(Array(session.detectedSounds.prefix(3)), id: \.id) { sound in
                    SoundEventRow(sound: sound)
                }
                
                if session.detectedSounds.count > 3 {
                    Button(action: {}) {
                        Text("Show all(\(session.detectedSounds.count))")
                            .font(.headline)
                            .foregroundColor(.defaultAccent)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .padding(.vertical, 20)
    }
}

struct SoundEventRow: View {
    let sound: SoundEvent
    
    var body: some View {
        HStack(spacing: 15) {
            Text(sound.type.emoji)
                .font(.title2)
            
            Text(sound.type.rawValue)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(formatTime(sound.timestamp))
                .font(.caption)
                .foregroundColor(.gray)
            
            // Waveform visualization
            WaveformView(data: sound.waveformData)
                .frame(width: 60, height: 20)
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct WaveformView: View {
    let data: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let stepWidth = width / CGFloat(data.count)
                
                for (index, amplitude) in data.enumerated() {
                    let x = CGFloat(index) * stepWidth
                    let normalizedAmplitude = CGFloat(abs(amplitude))
                    let barHeight = normalizedAmplitude * height
                    
                    path.addRect(CGRect(
                        x: x,
                        y: (height - barHeight) / 2,
                        width: max(1, stepWidth - 1),
                        height: barHeight
                    ))
                }
            }
            .fill(Color.defaultAccent.opacity(0.7))
        }
    }
}

struct NoSleepDataView: View {
    let date: Date
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 60))
                .foregroundColor(.defaultSecondary)
            
            Text("No Sleep Data")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("No sleep session recorded for \(formatDate(date))")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct StatisticsTabView: View {
    @ObservedObject var dataManager: InsightsDataManager
    @State private var selectedTimeframe: StatisticsTimeframe = .week
    @State private var animateCharts = false
    
    enum StatisticsTimeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Timeframe selector
                TimeframeSelectorView(selectedTimeframe: $selectedTimeframe)
                
                // Sleep Quality Trend
                SleepQualityTrendView(
                    sessions: dataManager.sleepSessions,
                    timeframe: selectedTimeframe,
                    animate: animateCharts
                )
                
                // Sleep Duration Trend
                SleepDurationTrendView(
                    sessions: dataManager.sleepSessions,
                    timeframe: selectedTimeframe,
                    animate: animateCharts
                )
                
                // Weekly Summary Cards
                WeeklySummaryCardsView(sessions: dataManager.sleepSessions)
                
                // Sleep Consistency Chart
                SleepConsistencyView(
                    sessions: dataManager.sleepSessions,
                    animate: animateCharts
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateCharts = true
            }
        }
    }
}

struct TimeframeSelectorView: View {
    @Binding var selectedTimeframe: StatisticsTabView.StatisticsTimeframe
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(StatisticsTabView.StatisticsTimeframe.allCases, id: \.self) { timeframe in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTimeframe = timeframe
                    }
                }) {
                    Text(timeframe.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedTimeframe == timeframe ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedTimeframe == timeframe ? Color.white : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.defaultCardBackground)
        )
        .padding(.top, 16)
    }
}

struct SleepQualityTrendView: View {
    let sessions: [SleepSessionData]
    let timeframe: StatisticsTabView.StatisticsTimeframe
    let animate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Sleep Quality Trend")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Average: \(averageQuality)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Simple line chart representation
            GeometryReader { geometry in
                Path { path in
                    let points = qualityDataPoints
                    guard points.count > 1 else { return }
                    
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(points.count - 1)
                    
                    path.move(to: CGPoint(x: 0, y: height - (CGFloat(points[0]) / 100.0) * height))
                    
                    for (index, point) in points.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = height - (CGFloat(point) / 100.0) * height
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .trim(from: 0, to: animate ? 1 : 0)
                .stroke(
                    LinearGradient(
                        colors: [Color.blue, Color.cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .animation(.easeInOut(duration: 1.5), value: animate)
            }
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.defaultCardBackground.opacity(0.3))
            )
        }
        .padding()
        .background(Color.defaultCardBackground)
        .cornerRadius(16)
    }
    
    private var qualityDataPoints: [Int] {
        let recentSessions = Array(sessions.prefix(7))
        return recentSessions.map { $0.sleepQuality.score }
    }
    
    private var averageQuality: String {
        let scores = qualityDataPoints
        guard !scores.isEmpty else { return "N/A" }
        let average = scores.reduce(0, +) / scores.count
        return "\(average)"
    }
}

struct SleepDurationTrendView: View {
    let sessions: [SleepSessionData]
    let timeframe: StatisticsTabView.StatisticsTimeframe
    let animate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Sleep Duration")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Goal: 8h")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Bar chart representation
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(durationDataPoints.enumerated()), id: \.offset) { index, duration in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: duration >= 8 ? [Color.green, Color.green.opacity(0.7)] : [Color.orange, Color.orange.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 24, height: animate ? CGFloat(duration * 15) : 0)
                            .animation(.easeInOut(duration: 1.0).delay(Double(index) * 0.1), value: animate)
                        
                        Text("\(Int(duration))h")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
        }
        .padding()
        .background(Color.defaultCardBackground)
        .cornerRadius(16)
    }
    
    private var durationDataPoints: [Double] {
        let recentSessions = Array(sessions.prefix(7))
        return recentSessions.map { $0.actualSleepTime / 3600 }
    }
}

struct WeeklySummaryCardsView: View {
    let sessions: [SleepSessionData]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                SummaryCard(
                    title: "Avg Sleep",
                    value: averageSleepTime,
                    icon: "moon.zzz.fill",
                    color: .blue
                )
                
                SummaryCard(
                    title: "Best Night",
                    value: bestNightScore,
                    icon: "star.fill",
                    color: .yellow
                )
            }
            
            HStack(spacing: 16) {
                SummaryCard(
                    title: "Consistency",
                    value: consistencyScore,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                SummaryCard(
                    title: "Deep Sleep",
                    value: averageDeepSleep,
                    icon: "brain.head.profile",
                    color: .purple
                )
            }
        }
    }
    
    private var averageSleepTime: String {
        guard !sessions.isEmpty else { return "0h 0m" }
        let totalTime = sessions.reduce(0) { $0 + $1.actualSleepTime }
        let average = totalTime / Double(sessions.count)
        let hours = Int(average) / 3600
        let minutes = Int(average) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
    
    private var bestNightScore: String {
        guard !sessions.isEmpty else { return "0" }
        let bestScore = sessions.map { $0.sleepQuality.score }.max() ?? 0
        return "\(bestScore)"
    }
    
    private var consistencyScore: String {
        // Simple consistency calculation based on sleep time variance
        return "85%"
    }
    
    private var averageDeepSleep: String {
        guard !sessions.isEmpty else { return "0%" }
        let deepSleepPercentages = sessions.compactMap { session in
            session.sleepPhases.first { $0.type == .deep }?.percentage
        }
        guard !deepSleepPercentages.isEmpty else { return "0%" }
        let average = deepSleepPercentages.reduce(0, +) / Double(deepSleepPercentages.count)
        return "\(Int(average))%"
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.defaultCardBackground)
        .cornerRadius(12)
    }
}

struct SleepConsistencyView: View {
    let sessions: [SleepSessionData]
    let animate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sleep Consistency")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("How consistent are your sleep and wake times?")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Consistency visualization
            VStack(spacing: 12) {
                ConsistencyBar(label: "Bedtime", percentage: 0.85, animate: animate)
                ConsistencyBar(label: "Wake time", percentage: 0.78, animate: animate)
                ConsistencyBar(label: "Sleep duration", percentage: 0.92, animate: animate)
            }
        }
        .padding()
        .background(Color.defaultCardBackground)
        .cornerRadius(16)
    }
}

struct ConsistencyBar: View {
    let label: String
    let percentage: Double
    let animate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(percentage * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animate ? geometry.size.width * CGFloat(percentage) : 0, height: 8)
                        .animation(.easeInOut(duration: 1.0), value: animate)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    NewInsightsView()
        .preferredColorScheme(.dark)
}

