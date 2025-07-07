//
//  BedtimeEditorSheet.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import SwiftUI

struct BedtimeEditorSheet: View {
    @ObservedObject var viewModel: SleepTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTime: Date
    
    init(viewModel: SleepTrackerViewModel) {
        self.viewModel = viewModel
        self._selectedTime = State(initialValue: viewModel.sleepSchedule.bedtime)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("Bedtime")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("When do you usually go to bed?")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                // Time Picker
                DatePicker(
                    "Bedtime",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
                
                Spacer()
                
                // Save Button
                Button(action: {
                    viewModel.sleepSchedule.bedtime = selectedTime
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
