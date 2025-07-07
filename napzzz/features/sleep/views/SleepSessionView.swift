//
//  SleepSessionView.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//
import SwiftUI

struct SleepSessionView: View {
    @ObservedObject var viewModel: SleepTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentTime = Date()
    @State private var ambientNoiseLevel: Double = 40
    @State private var showingSoundPicker = false
    @State private var showingWakeUpConfirmation = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                colors: [
                    Color.defaultBackground,
                    Color.purple.opacity(0.3),
                    Color.defaultBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ambient Noise")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "waveform")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("\(Int(ambientNoiseLevel)) dB")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Main Time Display
                VStack(spacing: 20) {
                    Text(formatCurrentTime())
                        .font(.system(size: 72, weight: .thin, design: .default))
                        .foregroundColor(.white)
                        .monospacedDigit()
                    
                    Text(formatCurrentDate())
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                // Animated Wave
                WaveView()
                    .frame(height: 100)
                    .padding(.top, 40)
                
                Spacer()
                
                // Control Buttons
                VStack(spacing: 20) {
                    // Sound & Music Button
                    Button(action: {
                        showingSoundPicker = true
                    }) {
                        HStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Color.defaultCardBackground)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "music.note")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sound & Music")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Choose relaxing sounds")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .background(Color.defaultCardBackground.opacity(0.5))
                        .cornerRadius(15)
                    }
                    
                    // Alarm Button
                    HStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.defaultCardBackground)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "alarm")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Alarm")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Smart wake up window")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(viewModel.formatTimeRange())
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(Color.defaultCardBackground.opacity(0.5))
                    .cornerRadius(15)
                }
                .padding(.horizontal, 20)
                
                // Wake Up Button
                Button(action: {
                    showingWakeUpConfirmation = true
                }) {
                    Text("Wake up")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.8), Color.red.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                
                Text("Tap to wake up")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
            // Simulate ambient noise level changes
            ambientNoiseLevel = Double.random(in: 35...45)
        }
        .sheet(isPresented: $showingSoundPicker) {
            SleepSoundPickerSheet()
        }
        .alert("Wake Up", isPresented: $showingWakeUpConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Wake Up") {
                wakeUpAndNavigateToInsights()
            }
        } message: {
            Text("Are you ready to wake up and see your sleep insights?")
        }
    }
    
    private func wakeUpAndNavigateToInsights() {
        // End the sleep session
        viewModel.endSleepSession()
        
        // Dismiss this view
        dismiss()
        
        // The MainTabView will automatically navigate to insights via the notification
    }
    
    private func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: currentTime)
    }
    
    private func formatCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd"
        return formatter.string(from: currentTime)
    }
}

struct WaveView: View {
    @State private var waveOffset = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midHeight = height / 2
                
                path.move(to: CGPoint(x: 0, y: midHeight))
                
                for x in stride(from: 0, through: width, by: 1) {
                    let relativeX = x / width
                    let sine = sin((relativeX + waveOffset) * 4 * .pi)
                    let y = midHeight + sine * 20
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(
                LinearGradient(
                    colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 3
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                waveOffset = 1
            }
        }
    }
}

struct SleepSoundPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            MusicView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(.defaultAccent)
                    }
                }
        }
    }
}

#Preview {
    SleepSessionView(viewModel: SleepTrackerViewModel())
        .preferredColorScheme(.dark)
}
