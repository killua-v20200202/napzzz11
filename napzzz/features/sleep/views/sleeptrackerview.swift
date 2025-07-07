//
//  sleeptrackerview.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import SwiftUI

struct SleepTrackerView: View {
    @StateObject private var viewModel = SleepTrackerViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.defaultBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    SleepTrackerHeader()
                    
                    // Main Content
                    ScrollView {
                        VStack(spacing: 30) {
                            // Circular Time Picker with proper padding
                            InteractiveCircularTimePicker(viewModel: viewModel)
                                .padding(.top, 40) // Increased top padding
                                .padding(.horizontal, 20) // Side padding for symbols
                            
                            // Time Controls with Centered Alarm
                            TimeControlsWithCenteredAlarm(viewModel: viewModel)
                            
                            // Sleep Button
                            SleepActionButton(viewModel: viewModel)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showingBedtimeEditor) {
                BedtimeEditorSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingAlarmEditor) {
                AlarmEditorSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingPreSleepActivities) {
                PreSleepActivitiesSheet(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $viewModel.showingSleepSession) {
                SleepSessionView(viewModel: viewModel)
            }
        }
    }
}

struct SleepTrackerHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sleep Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Napzz")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

struct InteractiveCircularTimePicker: View {
    @ObservedObject var viewModel: SleepTrackerViewModel
    @State private var isDraggingBedtime = false
    @State private var isDraggingWakeTime = false
    
    private let circleSize: CGFloat = 280
    private let trackWidth: CGFloat = 20
    private let handleSize: CGFloat = 40
    
    var body: some View {
        ZStack {
            // Background Circle Track
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: trackWidth)
                .frame(width: circleSize, height: circleSize)
            
            // Hour markers (just the tick marks, no numbers)
            ForEach(0..<24, id: \.self) { hour in
                HourTick(hour: hour, circleSize: circleSize)
            }
            
            // Sleep Duration Arc
            SleepDurationArc(
                bedtimeAngle: bedtimeAngle,
                wakeTimeAngle: wakeTimeAngle,
                circleSize: circleSize,
                trackWidth: trackWidth
            )
            
            // Bedtime Handle (Moon) - Only moves bedtime
            DraggableTimeHandle(
                angle: bedtimeAngle,
                circleSize: circleSize,
                icon: "moon.fill",
                color: .purple,
                isDragging: isDraggingBedtime,
                handleSize: handleSize
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDraggingBedtime = true
                        let angle = angleFromDragValue(value, circleSize: circleSize, handleSize: handleSize)
                        viewModel.updateBedtime(from: angle)
                    }
                    .onEnded { _ in
                        isDraggingBedtime = false
                    }
            )
            
            // Wake Time Handle (Sun) - Only moves wake time
            DraggableTimeHandle(
                angle: wakeTimeAngle,
                circleSize: circleSize,
                icon: "sun.max.fill",
                color: .orange,
                isDragging: isDraggingWakeTime,
                handleSize: handleSize
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDraggingWakeTime = true
                        let angle = angleFromDragValue(value, circleSize: circleSize, handleSize: handleSize)
                        viewModel.updateWakeTime(from: angle)
                    }
                    .onEnded { _ in
                        isDraggingWakeTime = false
                    }
            )
            
            // Center Sleep Duration Display
            VStack(spacing: 4) {
                Text(viewModel.sleepSchedule.formattedSleepDuration)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Sleep Duration")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: circleSize + handleSize + 40, height: circleSize + handleSize + 40) // Extra padding for handles
    }
    
    private var bedtimeAngle: Double {
        viewModel.angleForTime(viewModel.sleepSchedule.bedtime)
    }
    
    private var wakeTimeAngle: Double {
        viewModel.angleForTime(viewModel.sleepSchedule.wakeTime)
    }
    
    private func angleFromDragValue(_ value: DragGesture.Value, circleSize: CGFloat, handleSize: CGFloat) -> Double {
        let totalSize = circleSize + handleSize + 40
        let center = CGPoint(x: totalSize / 2, y: totalSize / 2)
        let location = CGPoint(
            x: value.location.x - center.x,
            y: value.location.y - center.y
        )
        
        let angle = atan2(location.y, location.x) * 180 / .pi + 90
        return angle < 0 ? angle + 360 : angle
    }
}

struct HourTick: View {
    let hour: Int
    let circleSize: CGFloat
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.gray.opacity(isMainHour ? 0.6 : 0.25))
                .frame(
                    width: isMainHour ? 2.5 : 1,
                    height: isMainHour ? 20 : 12
                )
            Spacer()
        }
        .frame(height: circleSize / 2 - 15)
        .rotationEffect(.degrees(Double(hour) * 15))
    }
    
    private var isMainHour: Bool {
        return [0, 6, 12, 18].contains(hour)
    }
}

struct SleepDurationArc: View {
    let bedtimeAngle: Double
    let wakeTimeAngle: Double
    let circleSize: CGFloat
    let trackWidth: CGFloat
    
    private var startAngle: Double {
        (bedtimeAngle - 90) * .pi / 180
    }
    
    private var endAngle: Double {
        let wake = wakeTimeAngle > bedtimeAngle ? wakeTimeAngle : wakeTimeAngle + 360
        return (wake - 90) * .pi / 180
    }
    
    var body: some View {
        Circle()
            .trim(from: 0, to: sweepAmount)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.9),
                        Color.blue.opacity(0.8),
                        Color.cyan.opacity(0.7)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: trackWidth, lineCap: .round)
            )
            .frame(width: circleSize, height: circleSize)
            .rotationEffect(.degrees(bedtimeAngle - 90))
            .shadow(color: Color.purple.opacity(0.3), radius: 6, x: 0, y: 0)
    }
    
    private var sweepAmount: Double {
        let bedtime = bedtimeAngle
        let wakeTime = wakeTimeAngle > bedtime ? wakeTimeAngle : wakeTimeAngle + 360
        return (wakeTime - bedtime) / 360
    }
}

struct DraggableTimeHandle: View {
    let angle: Double
    let circleSize: CGFloat
    let icon: String
    let color: Color
    let isDragging: Bool
    let handleSize: CGFloat
    
    private var handlePosition: CGPoint {
        let totalSize = circleSize + handleSize + 40
        let radius = circleSize / 2
        let angleInRadians = (angle - 90) * .pi / 180
        let x = totalSize / 2 + cos(angleInRadians) * radius
        let y = totalSize / 2 + sin(angleInRadians) * radius
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        ZStack {
            // Outer glow when dragging
            if isDragging {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .blur(radius: 8)
            }
            
            // Handle background
            Circle()
                .fill(Color.defaultBackground)
                .frame(width: handleSize, height: handleSize)
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: 3)
                )
                .shadow(color: color.opacity(0.4), radius: isDragging ? 8 : 4, x: 0, y: 0)
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
        }
        .position(handlePosition)
        .scaleEffect(isDragging ? 1.2 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
    }
}

struct TimeControlsWithCenteredAlarm: View {
    @ObservedObject var viewModel: SleepTrackerViewModel
    
    var body: some View {
        VStack(spacing: 25) {
            // Top Row: Bedtime and Wake Up
            HStack(spacing: 60) {
                // Bedtime Column
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.purple)
                        Text("Bedtime")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        viewModel.showingBedtimeEditor = true
                    }) {
                        HStack(spacing: 4) {
                            Text(viewModel.formatTime(viewModel.sleepSchedule.bedtime))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Wake Up Column
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.orange)
                        Text("Wake Up")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        viewModel.showingAlarmEditor = true
                    }) {
                        HStack(spacing: 4) {
                            Text(viewModel.formatTime(viewModel.sleepSchedule.wakeTime))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            // Bottom Row: Centered Alarm
            HStack(spacing: 8) {
                // Spacer to center the alarm section
                Spacer()
                
                // Alarm Icon and Text (moved slightly right)
                HStack(spacing: 8) {
                    Image(systemName: "alarm.fill")
                        .font(.title3)
                        .foregroundColor(.defaultAccent)
                    
                    Text("Alarm")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.leading, 20) // Move slightly to the right
                
                // Edit Button (same size as other edit buttons)
                Button(action: {
                    viewModel.showingAlarmEditor = true
                }) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Spacer to balance the layout
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
}

struct SleepActionButton: View {
    @ObservedObject var viewModel: SleepTrackerViewModel
    
    var body: some View {
        Button(action: {
            if viewModel.isTrackingSleep {
                viewModel.endSleepSession()
            } else {
                viewModel.startSleepFlow()
            }
        }) {
            Text(viewModel.isTrackingSleep ? "Wake Up" : "Sleep Now")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.white)
                .cornerRadius(30)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

#Preview {
    SleepTrackerView()
        .preferredColorScheme(.dark)
}
