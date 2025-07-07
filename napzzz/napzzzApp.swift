//
//  napzzzApp.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//
import SwiftUI

@main
struct NapzzApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
