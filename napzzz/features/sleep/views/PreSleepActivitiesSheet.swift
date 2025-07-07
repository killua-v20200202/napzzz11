//
//  PreSleepActivitiesSheet.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import SwiftUI

struct PreSleepActivitiesSheet: View {
    @ObservedObject var viewModel: SleepTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.defaultBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Content
                VStack(spacing: 30) {
                    // Title
                    VStack(spacing: 12) {
                        Text("Take a note before sleep")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("What did you do before going to bed?")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Activities Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(SleepActivity.allCases) { activity in
                            ActivityButton(
                                activity: activity,
                                isSelected: viewModel.isActivitySelected(activity)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.toggleActivity(activity)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            viewModel.proceedToSleepSession()
                        }) {
                            Text("Next")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.white)
                                .cornerRadius(30)
                        }
                        
                        Button(action: {
                            viewModel.skipPreSleepActivities()
                        }) {
                            Text("Skip")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct ActivityButton: View {
    let activity: SleepActivity
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(activity.emoji)
                    .font(.title2)
                
                Text(activity.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(isSelected ? Color.defaultAccent.opacity(0.3) : Color.defaultCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(isSelected ? Color.defaultAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
