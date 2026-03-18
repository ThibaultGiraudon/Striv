//
//  StreakView.swift
//  Striv
//
//  Created by Thibault Giraudon on 16/03/2026.
//

import SwiftUI

struct StreakView: View {
    var currentStreak: Int
    var body: some View {
        HStack {
            VStack {
                ZStack(alignment: .bottom) {
                    Image(systemName: "flame")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                        .foregroundStyle(.red)
                    Image(systemName: "flame.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                        .foregroundStyle(.red)
                    Text("\(currentStreak)")
                        .foregroundStyle(Color.background)
                        .font(.title2.bold())
                        .padding(.bottom, 5)
                }
                Text("Current Streak")
                    .foregroundStyle(.red)
                    .bold()
            }
            Text("\(currentStreak) semaine\(currentStreak > 1 ? "s" : "") d'activité consécutives.")
                .font(.title2.bold())
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
}

#Preview {
    StreakView(currentStreak: 20)
}
