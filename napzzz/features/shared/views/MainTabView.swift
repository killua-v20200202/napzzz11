//
//  MainTabView.swift
//  napzzz
//
//  Created by Morris Romagnoli on 07/07/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            MusicView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "music.note" : "music.note")
                    Text("Sounds")
                }
                .tag(1)
            
            SleepBuddyView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "brain.head.profile" : "brain.head.profile")
                    Text("Sleep Buddy")
                }
                .tag(2)
            
            RoutineView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "moon.fill" : "moon")
                    Text("Sleep")
                }
                .tag(3)
            
            NewInsightsView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "chart.bar.fill" : "chart.bar")
                    Text("Insights")
                }
                .tag(4)
        }
        .accentColor(.defaultAccent)
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: .sleepSessionCompleted)) { _ in
            // Navigate to Insights tab when sleep session is completed
            withAnimation(.easeInOut(duration: 0.5)) {
                selectedTab = 4
            }
        }
    }
}

#Preview {
    MainTabView()
}
