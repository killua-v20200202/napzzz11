//
//  color+theme.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import SwiftUI

extension Color {
    // Primary Colors
    static let napzzzPrimary = Color("NapzzPrimary")
    static let napzzzSecondary = Color("NapzzSecondary")
    static let napzzzAccent = Color("NapzzAccent")
    
    // Background Colors
    static let napzzzBackground = Color("NapzzBackground")
    static let napzzzCardBackground = Color("NapzzCardBackground")
    
    // Text Colors
    static let napzzzTextPrimary = Color("NapzzTextPrimary")
    static let napzzzTextSecondary = Color("NapzzTextSecondary")
    
    // Default values for when assets aren't available
    static let defaultPrimary = Color(red: 0.2, green: 0.6, blue: 0.6)
    static let defaultSecondary = Color(red: 0.7, green: 0.6, blue: 0.8)
    static let defaultAccent = Color(red: 1.0, green: 0.7, blue: 0.5)
    static let defaultBackground = Color(red: 0.1, green: 0.1, blue: 0.2)
    static let defaultCardBackground = Color(red: 0.15, green: 0.15, blue: 0.25)
}
