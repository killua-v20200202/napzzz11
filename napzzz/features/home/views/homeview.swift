//
//  homeview.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HeaderView()
                    
                    // Featured Content
                    FeaturedContentView()
                    
                    // Categories
                    CategoriesView()
                    
                    // Recent Activity
                    RecentActivityView()
                }
                .padding(.horizontal)
            }
            .background(Color.defaultBackground)
            .navigationBarHidden(true)
        }
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Good evening")
                    .font(.title2)
                    .foregroundColor(.defaultSecondary)
                
                Text("Ready for better sleep?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: {
                // Search action
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 20)
    }
}

struct FeaturedContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("To get you started")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    FeaturedCard(
                        title: "Fall Asleep Fast",
                        subtitle: "Playlist • 6 h 19 min",
                        imageName: "moon.stars.fill",
                        color: .defaultPrimary
                    )
                    
                    FeaturedCard(
                        title: "Deep Sleep Meditation",
                        subtitle: "Meditation • 45 min",
                        imageName: "leaf.fill",
                        color: .defaultSecondary
                    )
                    
                    FeaturedCard(
                        title: "Ocean Waves",
                        subtitle: "Nature Sounds • 8 hours",
                        imageName: "water.waves",
                        color: .defaultAccent
                    )
                }
                .padding(.horizontal, 5)
            }
        }
    }
}

struct FeaturedCard: View {
    let title: String
    let subtitle: String
    let imageName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.opacity(0.3))
                    .frame(width: 200, height: 120)
                
                Image(systemName: imageName)
                    .font(.system(size: 40))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.defaultSecondary)
            }
        }
        .frame(width: 200)
    }
}

struct CategoriesView: View {
    let categories = [
        ("SleepTales", "book.fill", Color.green),
        ("Meditations", "figure.mind.and.body", Color.purple),
        ("Music", "music.note", Color.orange),
        ("Nature", "leaf.fill", Color.blue)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Categories")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(categories, id: \.0) { category in
                    CategoryCard(
                        title: category.0,
                        icon: category.1,
                        color: category.2
                    )
                }
            }
        }
    }
}

struct CategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(Color.defaultCardBackground)
        .cornerRadius(12)
    }
}

struct RecentActivityView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                RecentActivityItem(
                    title: "Rain Sounds",
                    subtitle: "Last played 2 hours ago",
                    icon: "cloud.rain.fill"
                )
                
                RecentActivityItem(
                    title: "Bedtime Story",
                    subtitle: "Last played yesterday",
                    icon: "book.fill"
                )
            }
        }
        .padding(.bottom, 100) // Space for tab bar
    }
}

struct RecentActivityItem: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.defaultAccent)
                .frame(width: 40, height: 40)
                .background(Color.defaultAccent.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.defaultSecondary)
            }
            
            Spacer()
            
            Button(action: {
                // Play action
            }) {
                Image(systemName: "play.fill")
                    .font(.title3)
                    .foregroundColor(.defaultAccent)
            }
        }
        .padding()
        .background(Color.defaultCardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
