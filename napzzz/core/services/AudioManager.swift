//
//  AudioManager.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//
import Foundation
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    @Published var isPlaying = false
    @Published var activePlayers: [String: AVAudioPlayer] = [:]
    @Published var currentVolumes: [String: Float] = [:]
    @Published var activePlayerCount = 0
    
    private var audioSession: AVAudioSession
    private var cancellables = Set<AnyCancellable>()
    private var generatedFileURLs: [String: URL] = [:]
    
    override init() {
        self.audioSession = AVAudioSession.sharedInstance()
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try audioSession.setActive(true)
            print("✅ Audio session configured successfully")
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Main Playback Functions
    
    func playSound(_ soundItem: SoundItem) {
        let soundId = soundItem.id.uuidString
        
        // Check if we already have a player for this sound
        if let existingPlayer = activePlayers[soundId] {
            if !existingPlayer.isPlaying {
                existingPlayer.play()
                print("▶️ Resumed: \(soundItem.name)")
            }
            updatePlayingState()
            return
        }
        
        // Try to load real audio file first
        if let url = Bundle.main.url(forResource: soundItem.fileName.replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") {
            createRealPlayer(for: soundItem, url: url)
        } else {
            // Create generated audio for demonstration
            createGeneratedPlayer(for: soundItem)
        }
    }
    
    func stopSound(_ soundItem: SoundItem) {
        let soundId = soundItem.id.uuidString
        
        if let player = activePlayers[soundId] {
            player.stop()
            activePlayers.removeValue(forKey: soundId)
            currentVolumes.removeValue(forKey: soundId)
            
            // Clean up generated file if it exists
            if let fileURL = generatedFileURLs[soundId] {
                try? FileManager.default.removeItem(at: fileURL)
                generatedFileURLs.removeValue(forKey: soundId)
            }
            
            print("⏹️ Stopped: \(soundItem.name)")
            updatePlayingState()
        }
    }
    
    func stopAllSounds() {
        print("⏹️ Stopping all sounds...")
        
        // Stop all players
        activePlayers.values.forEach { $0.stop() }
        
        // Clean up all generated files
        for (_, fileURL) in generatedFileURLs {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        // Clear all collections
        activePlayers.removeAll()
        currentVolumes.removeAll()
        generatedFileURLs.removeAll()
        
        updatePlayingState()
    }
    
    func pauseAllSounds() {
        activePlayers.values.forEach { $0.pause() }
        print("⏸️ Paused all sounds")
        updatePlayingState()
    }
    
    func resumeAllSounds() {
        activePlayers.values.forEach { $0.play() }
        print("▶️ Resumed all sounds")
        updatePlayingState()
    }
    
    // MARK: - Volume Control
    
    func setVolume(for soundItem: SoundItem, volume: Float) {
        let soundId = soundItem.id.uuidString
        let clampedVolume = max(0.0, min(1.0, volume))
        
        activePlayers[soundId]?.volume = clampedVolume
        currentVolumes[soundId] = clampedVolume
        
        print("🔊 Volume for \(soundItem.name): \(Int(clampedVolume * 100))%")
    }
    
    func getCurrentVolume(for soundItem: SoundItem) -> Float {
        let soundId = soundItem.id.uuidString
        return currentVolumes[soundId] ?? soundItem.volume
    }
    
    // MARK: - Status Checking
    
    func isSoundPlaying(_ soundItem: SoundItem) -> Bool {
        let soundId = soundItem.id.uuidString
        return activePlayers[soundId]?.isPlaying ?? false
    }
    
    func isSoundActive(_ soundItem: SoundItem) -> Bool {
        let soundId = soundItem.id.uuidString
        return activePlayers[soundId] != nil
    }
    
    // MARK: - Real Audio Player Creation
    
    private func createRealPlayer(for soundItem: SoundItem, url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            setupPlayer(player, for: soundItem, isReal: true)
            print("✅ Playing real audio: \(soundItem.name)")
        } catch {
            print("❌ Failed to create real player for \(soundItem.name): \(error)")
            createGeneratedPlayer(for: soundItem)
        }
    }
    
    // MARK: - Generated Audio Player Creation
    
    private func createGeneratedPlayer(for soundItem: SoundItem) {
        let soundId = soundItem.id.uuidString
        
        // Generate appropriate audio based on sound type
        if let audioURL = generateAudioForSound(soundItem) {
            do {
                let player = try AVAudioPlayer(contentsOf: audioURL)
                setupPlayer(player, for: soundItem, isReal: false)
                generatedFileURLs[soundId] = audioURL
                print("🎵 Playing generated audio: \(soundItem.name)")
            } catch {
                print("❌ Failed to create generated player for \(soundItem.name): \(error)")
            }
        }
    }
    
    private func setupPlayer(_ player: AVAudioPlayer, for soundItem: SoundItem, isReal: Bool) {
        let soundId = soundItem.id.uuidString
        
        player.numberOfLoops = -1 // Loop indefinitely
        player.volume = isReal ? soundItem.volume : (soundItem.volume * 0.4) // Lower volume for generated sounds
        player.delegate = self
        player.prepareToPlay()
        
        activePlayers[soundId] = player
        currentVolumes[soundId] = player.volume
        
        player.play()
        updatePlayingState()
    }
    
    // MARK: - Audio Generation
    
    private func generateAudioForSound(_ soundItem: SoundItem) -> URL? {
        let soundId = soundItem.id.uuidString
        let soundName = soundItem.name.lowercased()
        
        // Determine audio generation method based on sound type
        if soundName.contains("noise") {
            return generateNoiseAudio(type: getNoiseType(soundName), soundId: soundId)
        } else if soundName.contains("rain") || soundName.contains("water") || soundName.contains("ocean") {
            return generateNatureAudio(type: .water, soundId: soundId)
        } else if soundName.contains("wind") {
            return generateNatureAudio(type: .wind, soundId: soundId)
        } else if soundName.contains("fire") {
            return generateNatureAudio(type: .fire, soundId: soundId)
        } else {
            return generateToneAudio(frequency: getFrequencyForSound(soundName), soundId: soundId)
        }
    }
    
    private enum NoiseType {
        case white, pink, brown, green
    }
    
    private enum NatureType {
        case water, wind, fire
    }
    
    private func getNoiseType(_ soundName: String) -> NoiseType {
        if soundName.contains("pink") { return .pink }
        if soundName.contains("brown") { return .brown }
        if soundName.contains("green") { return .green }
        return .white
    }
    
    private func getFrequencyForSound(_ soundName: String) -> Float {
        switch soundName {
        case let name where name.contains("bell"):
            return 440.0
        case let name where name.contains("bowl"):
            return 256.0
        case let name where name.contains("deep"):
            return 60.0
        case let name where name.contains("forest"):
            return 180.0
        case let name where name.contains("bird"):
            return 800.0
        case let name where name.contains("thunder"):
            return 80.0
        default:
            return 220.0
        }
    }
    
    private func generateNoiseAudio(type: NoiseType, soundId: String) -> URL? {
        let sampleRate: Double = 44100
        let duration: Double = 10.0
        let samples = Int(sampleRate * duration)
        
        var audioData = [Float]()
        
        for i in 0..<samples {
            let sample: Float
            
            switch type {
            case .white:
                sample = Float.random(in: -0.1...0.1)
            case .pink:
                // Simplified pink noise (1/f noise approximation)
                let frequency = 100.0 + Double(i % 1000) / 10.0
                sample = Float(0.05 * sin(2.0 * Double.pi * frequency * Double(i) / sampleRate))
            case .brown:
                // Simplified brown noise (1/f² noise approximation)
                let frequency = 50.0 + Double(i % 500) / 20.0
                sample = Float(0.03 * sin(2.0 * Double.pi * frequency * Double(i) / sampleRate))
            case .green:
                // Green noise (nature-like frequency distribution)
                let frequency = 200.0 + Double(i % 2000) / 5.0
                sample = Float(0.04 * sin(2.0 * Double.pi * frequency * Double(i) / sampleRate))
            }
            
            audioData.append(sample)
        }
        
        return saveAudioData(audioData, sampleRate: sampleRate, soundId: soundId)
    }
    
    private func generateNatureAudio(type: NatureType, soundId: String) -> URL? {
        let sampleRate: Double = 44100
        let duration: Double = 10.0
        let samples = Int(sampleRate * duration)
        
        var audioData = [Float]()
        
        for i in 0..<samples {
            let time = Double(i) / sampleRate
            let sample: Float
            
            switch type {
            case .water:
                // Simulate water/rain with multiple frequencies and random modulation
                let base = 0.02 * sin(Float(2.0 * Double.pi * 150.0 * time))
                let ripple = 0.01 * sin(Float(2.0 * Double.pi * 300.0 * time))
                let noise = Float.random(in: -0.005...0.005)
                sample = base + ripple + noise
                
            case .wind:
                // Simulate wind with low frequency and random variations
                let base = 0.03 * sin(Float(2.0 * Double.pi * 80.0 * time))
                let gust = 0.02 * sin(Float(2.0 * Double.pi * 120.0 * time + Double.pi/4))
                let noise = Float.random(in: -0.01...0.01)
                sample = base + gust + noise
                
            case .fire:
                // Simulate fire crackling with random pops and low rumble
                let rumble = 0.02 * sin(Float(2.0 * Double.pi * 60.0 * time))
                let crackle = Float.random(in: -0.03...0.03)
                sample = rumble + crackle
            }
            
            audioData.append(sample)
        }
        
        return saveAudioData(audioData, sampleRate: sampleRate, soundId: soundId)
    }
    
    private func generateToneAudio(frequency: Float, soundId: String) -> URL? {
        let sampleRate: Double = 44100
        let duration: Double = 10.0
        let samples = Int(sampleRate * duration)
        
        var audioData = [Float]()
        
        for i in 0..<samples {
            let time = Double(i) / sampleRate
            let amplitude: Float = 0.05
            let sample = amplitude * sin(Float(2.0 * Double.pi * Double(frequency) * time))
            audioData.append(sample)
        }
        
        return saveAudioData(audioData, sampleRate: sampleRate, soundId: soundId)
    }
    
    private func saveAudioData(_ audioData: [Float], sampleRate: Double, soundId: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent("generated_\(soundId).wav")
        
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        do {
            let audioFile = try AVAudioFile(forWriting: audioURL, settings: audioFormat.settings)
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(audioData.count))!
            
            audioBuffer.frameLength = AVAudioFrameCount(audioData.count)
            
            let channelData = audioBuffer.floatChannelData![0]
            for i in 0..<audioData.count {
                channelData[i] = audioData[i]
            }
            
            try audioFile.write(from: audioBuffer)
            return audioURL
        } catch {
            print("❌ Failed to save audio data: \(error)")
            return nil
        }
    }
    
    // MARK: - State Management
    
    private func updatePlayingState() {
        let playingCount = activePlayers.values.filter { $0.isPlaying }.count
        isPlaying = playingCount > 0
        activePlayerCount = activePlayers.count
        
        print("🎵 Active sounds: \(activePlayerCount), Playing: \(playingCount)")
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Find and remove the finished player
        for (soundId, activePlayer) in activePlayers {
            if activePlayer == player {
                activePlayers.removeValue(forKey: soundId)
                currentVolumes.removeValue(forKey: soundId)
                
                // Clean up generated file
                if let fileURL = generatedFileURLs[soundId] {
                    try? FileManager.default.removeItem(at: fileURL)
                    generatedFileURLs.removeValue(forKey: soundId)
                }
                
                print("🔚 Audio finished: \(soundId)")
                break
            }
        }
        updatePlayingState()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("❌ Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        print("🔇 Audio interrupted")
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        print("🔊 Audio interruption ended")
        if flags == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
            player.play()
        }
    }
}
