//
//  sounditem.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import Foundation

struct SoundItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let iconName: String
    let category: SoundCategory
    let fileName: String // For future audio file reference
    var isPlaying: Bool = false
    var volume: Float = 0.7
}

enum SoundCategory: String, CaseIterable {
    case all = "All"
    case popular = "Popular"
    case favorites = "My ❤️"
    case new = "New"
    case whiteNoise = "White Noise"
    
    var displayName: String {
        return self.rawValue
    }
}
