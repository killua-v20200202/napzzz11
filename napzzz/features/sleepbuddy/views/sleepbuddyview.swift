//
//  sleepbuddyview.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import SwiftUI

struct SleepBuddyView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Sleep Buddy AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Your AI sleep companion")
                    .font(.title2)
                    .foregroundColor(.defaultSecondary)
                    .padding(.top, 20)
                
                Text("Coming soon...")
                    .font(.title3)
                    .foregroundColor(.defaultSecondary)
                    .padding(.top, 50)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.defaultBackground)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SleepBuddyView()
        .preferredColorScheme(.dark)
}
