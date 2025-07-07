//
//  soundsviewmodel.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import Foundation
import Combine

class SoundsViewModel: ObservableObject {
    @Published var sounds: [SoundItem] = []
    @Published var selectedCategory: SoundCategory = .all
    @Published var activeSounds: Set<SoundItem> = []
    @Published var currentMixName: String = "Your First Mix"
    @Published var isPlaying: Bool = false
    @Published var activePlayerCount: Int = 0
    
    private let audioManager = AudioManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSounds()
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind audio manager's playing state to our view model
        audioManager.$isPlaying
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)
        
        audioManager.$activePlayerCount
            .assign(to: \.activePlayerCount, on: self)
            .store(in: &cancellables)
        
        // Update active sounds based on audio manager state
        audioManager.$activePlayers
            .map { players in
                Set(self.sounds.filter { sound in
                    players.keys.contains(sound.id.uuidString)
                })
            }
            .assign(to: \.activeSounds, on: self)
            .store(in: &cancellables)
        
        // Update mix name when active sounds change
        $activeSounds
            .sink { [weak self] _ in
                self?.updateMixName()
            }
            .store(in: &cancellables)
    }
    
    var filteredSounds: [SoundItem] {
        switch selectedCategory {
        case .all:
            return sounds
        case .popular:
            return sounds.filter { popularSoundNames.contains($0.name) }
        case .favorites:
            return sounds.filter { favoriteSoundNames.contains($0.name) }
        case .new:
            return Array(sounds.suffix(8)) // Show last 8 as "new"
        case .whiteNoise:
            return sounds.filter { $0.name.lowercased().contains("noise") }
        }
    }
    
    private let popularSoundNames = [
        "Rain", "Ocean Waves", "Forest", "White Noise", "Pink Noise",
        "Thunder", "Fireplace", "Wind", "Coffee Shop", "Fan"
    ]
    
    private let favoriteSoundNames = [
        "Rain", "Ocean Waves", "Forest", "Meditation Bell", "Deep Space"
    ]
    
    // MARK: - Sound Control Functions
    
    func toggleSound(_ sound: SoundItem) {
        if isSoundActive(sound) {
            // Stop the sound
            audioManager.stopSound(sound)
            print("🔴 Stopped: \(sound.name)")
        } else {
            // Start the sound
            audioManager.playSound(sound)
            print("🟢 Started: \(sound.name)")
        }
    }
    
    func isSoundActive(_ sound: SoundItem) -> Bool {
        return audioManager.isSoundActive(sound)
    }
    
    func isSoundPlaying(_ sound: SoundItem) -> Bool {
        return audioManager.isSoundPlaying(sound)
    }
    
    func pauseAllSounds() {
        audioManager.pauseAllSounds()
    }
    
    func resumeAllSounds() {
        audioManager.resumeAllSounds()
    }
    
    func stopAllSounds() {
        audioManager.stopAllSounds()
    }
    
    func setSoundVolume(_ sound: SoundItem, volume: Float) {
        audioManager.setVolume(for: sound, volume: volume)
    }
    
    func getSoundVolume(_ sound: SoundItem) -> Float {
        return audioManager.getCurrentVolume(for: sound)
    }
    
    // MARK: - Mix Management
    
    private func updateMixName() {
        if activeSounds.isEmpty {
            currentMixName = "Your First Mix"
        } else if activeSounds.count == 1 {
            currentMixName = activeSounds.first?.name ?? "Custom Mix"
        } else {
            let sortedSounds = Array(activeSounds).sorted { $0.name < $1.name }
            let soundNames = Array(sortedSounds.prefix(2)).map { $0.name }
            currentMixName = soundNames.joined(separator: " + ")
            if activeSounds.count > 2 {
                currentMixName += " + \(activeSounds.count - 2) more"
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func loadSounds() {
        sounds = [
            // Nature Sounds
            SoundItem(name: "Rain", iconName: "cloud.rain.fill", category: .popular, fileName: "rain.mp3"),
            SoundItem(name: "Ocean Waves", iconName: "water.waves", category: .popular, fileName: "ocean.mp3"),
            SoundItem(name: "Forest", iconName: "tree.fill", category: .popular, fileName: "forest.mp3"),
            SoundItem(name: "Thunder", iconName: "cloud.bolt.fill", category: .popular, fileName: "thunder.mp3"),
            SoundItem(name: "Wind", iconName: "wind", category: .all, fileName: "wind.mp3"),
            SoundItem(name: "Birds", iconName: "bird.fill", category: .all, fileName: "birds.mp3"),
            SoundItem(name: "Waterfall", iconName: "drop.fill", category: .all, fileName: "waterfall.mp3"),
            SoundItem(name: "Fireplace", iconName: "flame.fill", category: .popular, fileName: "fireplace.mp3"),
            
            // White/Pink/Brown Noise
            SoundItem(name: "White Noise", iconName: "waveform", category: .whiteNoise, fileName: "white_noise.mp3"),
            SoundItem(name: "Pink Noise", iconName: "waveform.path", category: .whiteNoise, fileName: "pink_noise.mp3"),
            SoundItem(name: "Brown Noise", iconName: "waveform.path.ecg", category: .whiteNoise, fileName: "brown_noise.mp3"),
            SoundItem(name: "Green Noise", iconName: "waveform.path.badge.plus", category: .whiteNoise, fileName: "green_noise.mp3"),
            
            // Ambient/Electronic
            SoundItem(name: "Deep Space", iconName: "sparkles", category: .new, fileName: "deep_space.mp3"),
            SoundItem(name: "Meditation Bell", iconName: "bell.fill", category: .all, fileName: "bell.mp3"),
            SoundItem(name: "Tibetan Bowl", iconName: "circle.fill", category: .all, fileName: "tibetan_bowl.mp3"),
            SoundItem(name: "Binaural Beats", iconName: "brain.head.profile", category: .new, fileName: "binaural.mp3"),
            
            // Urban/Mechanical
            SoundItem(name: "City Rain", iconName: "building.2.fill", category: .all, fileName: "city_rain.mp3"),
            SoundItem(name: "Coffee Shop", iconName: "cup.and.saucer.fill", category: .popular, fileName: "coffee_shop.mp3"),
            SoundItem(name: "Train", iconName: "tram.fill", category: .all, fileName: "train.mp3"),
            SoundItem(name: "Fan", iconName: "fan.fill", category: .all, fileName: "fan.mp3"),
            
            // Seasonal/Special
            SoundItem(name: "Winter Wind", iconName: "snowflake", category: .new, fileName: "winter_wind.mp3"),
            SoundItem(name: "Spring Rain", iconName: "leaf.fill", category: .new, fileName: "spring_rain.mp3"),
            SoundItem(name: "Summer Night", iconName: "moon.stars.fill", category: .new, fileName: "summer_night.mp3"),
            SoundItem(name: "Autumn Leaves", iconName: "leaf.arrow.circlepath", category: .new, fileName: "autumn_leaves.mp3")
        ]
    }
}
