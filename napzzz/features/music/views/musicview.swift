//
//  musicview.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//
import SwiftUI

struct MusicView: View {
    @StateObject private var viewModel = SoundsViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                MusicHeaderSection()
                
                // Category Filter
                CategoryFilterSection(selectedCategory: $viewModel.selectedCategory)
                
                // Sounds Grid
                SoundsGridSection(viewModel: viewModel)
                
                // Current Mix Player (if sounds are active)
                if !viewModel.activeSounds.isEmpty {
                    CurrentMixPlayer(viewModel: viewModel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(Color.defaultBackground)
            .navigationBarHidden(true)
        }
    }
}

struct MusicHeaderSection: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 20) {
                    Text("Sounds")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Music")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Text("Mixes")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 80, height: 2)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "leaf.circle.fill")
                    .font(.title2)
                    .foregroundColor(.defaultAccent)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

struct CategoryFilterSection: View {
    @Binding var selectedCategory: SoundCategory
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SoundCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.white : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                        )
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct SoundsGridSection: View {
    @ObservedObject var viewModel: SoundsViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.filteredSounds) { sound in
                    SoundCard(
                        sound: sound,
                        isActive: viewModel.isSoundActive(sound),
                        isPlaying: viewModel.isSoundPlaying(sound)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.toggleSound(sound)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, viewModel.activeSounds.isEmpty ? 100 : 180)
        }
    }
}

struct SoundCard: View {
    let sound: SoundItem
    let isActive: Bool
    let isPlaying: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Card Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.defaultCardBackground)
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isActive ? Color.defaultAccent : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: isActive ? Color.defaultAccent.opacity(0.3) : Color.clear, radius: 8)
                
                // Icon
                Image(systemName: sound.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(isActive ? .defaultAccent : .white)
                    .scaleEffect(isPlaying ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isPlaying)
                
                // Active indicator
                if isActive {
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.defaultBackground)
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: isPlaying ? "speaker.wave.2.fill" : "pause.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.defaultAccent)
                            }
                        }
                        Spacer()
                    }
                    .padding(8)
                }
            }
            .scaleEffect(isActive ? 1.05 : (isPressed ? 0.95 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            
            Text(sound.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct CurrentMixPlayer: View {
    @ObservedObject var viewModel: SoundsViewModel
    @State private var showVolumeControls = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            VStack(spacing: 0) {
                // Main Player Row - Fixed Height
                HStack(spacing: 15) {
                    // Mix Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.defaultAccent.opacity(0.3), Color.defaultPrimary.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        if let firstSound = viewModel.activeSounds.first {
                            Image(systemName: firstSound.iconName)
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        
                        // Multiple sounds indicator
                        if viewModel.activeSounds.count > 1 {
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("\(viewModel.activeSounds.count)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                        .background(Color.defaultAccent)
                                        .clipShape(Circle())
                                }
                                Spacer()
                            }
                            .padding(4)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.currentMixName)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("\(viewModel.activeSounds.count) sound\(viewModel.activeSounds.count == 1 ? "" : "s") playing")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Volume button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showVolumeControls.toggle()
                        }
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(showVolumeControls ? 180 : 0))
                    }
                    
                    // Stop all button
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.stopAllSounds()
                        }
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    
                    // Play/Pause button
                    Button(action: {
                        if viewModel.isPlaying {
                            viewModel.pauseAllSounds()
                        } else {
                            viewModel.resumeAllSounds()
                        }
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [Color.defaultAccent, Color.defaultPrimary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .scaleEffect(viewModel.isPlaying ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.isPlaying)
                    }
                }
                .frame(height: 70) // Fixed height for main player row
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                
                // Volume Controls (expandable) - Separate container
                if showVolumeControls {
                    VStack(spacing: 10) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                        
                        Text("Volume Controls")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                        
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(Array(viewModel.activeSounds), id: \.id) { sound in
                                    VolumeSlider(sound: sound, viewModel: viewModel)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .frame(maxHeight: 200) // Limit height for many sounds
                        .padding(.bottom, 15)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.2),
                        Color.blue.opacity(0.2),
                        Color.defaultPrimary.opacity(0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

struct VolumeSlider: View {
    let sound: SoundItem
    @ObservedObject var viewModel: SoundsViewModel
    @State private var volume: Float = 0.7
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: sound.iconName)
                .font(.caption)
                .foregroundColor(.defaultAccent)
                .frame(width: 20)
            
            Text(sound.name)
                .font(.caption)
                .foregroundColor(.white)
                .frame(maxWidth: 80, alignment: .leading)
                .lineLimit(1)
            
            Slider(value: $volume, in: 0...1, step: 0.1)
                .accentColor(.defaultAccent)
                .onChange(of: volume) { newValue in
                    viewModel.setSoundVolume(sound, volume: newValue)
                }
            
            Text("\(Int(volume * 100))%")
                .font(.caption2)
                .foregroundColor(.gray)
                .frame(width: 30)
        }
        .onAppear {
            volume = viewModel.getSoundVolume(sound)
        }
    }
}

#Preview {
    MusicView()
        .preferredColorScheme(.dark)
}
