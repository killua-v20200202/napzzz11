//
//  AlarmeditorSheet.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import SwiftUI

struct AlarmEditorSheet: View {
    @ObservedObject var viewModel: SleepTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWakeTime: Date
    @State private var selectedTone: AlarmTone
    
    init(viewModel: SleepTrackerViewModel) {
        self.viewModel = viewModel
        self._selectedWakeTime = State(initialValue: viewModel.sleepSchedule.wakeTime)
        self._selectedTone = State(initialValue: viewModel.selectedAlarmTone)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("Alarm")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Set your wake up time and alarm tone")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Time Picker
                VStack(alignment: .leading, spacing: 15) {
                    Text("Wake Time")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    DatePicker(
                        "Wake Time",
                        selection: $selectedWakeTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                }
                
                // Alarm Tone Selection
                VStack(alignment: .leading, spacing: 15) {
                    Text("Alarm Tone")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(AlarmTone.allCases) { tone in
                                AlarmToneRow(
                                    tone: tone,
                                    isSelected: selectedTone == tone,
                                    onSelect: { selectedTone = tone },
                                    onPreview: { viewModel.previewAlarmTone(tone) }
                                )
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                
                Spacer()
                
                // Save Button
                Button(action: {
                    viewModel.sleepSchedule.wakeTime = selectedWakeTime
                    viewModel.selectedAlarmTone = selectedTone
                    dismiss()
                }) {
                    Text("Save")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
            .background(Color.defaultBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
        }
    }
}

struct AlarmToneRow: View {
    let tone: AlarmTone
    let isSelected: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: onSelect) {
                HStack(spacing: 15) {
                    // Selection indicator
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if isSelected {
                            Circle()
                                .fill(Color.defaultAccent)
                                .frame(width: 16, height: 16)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tone.rawValue)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(tone.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
            }
            
            // Preview button
            Button(action: onPreview) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.defaultAccent)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.defaultAccent.opacity(0.1) : Color.defaultCardBackground)
        )
    }
}
