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
            ZStack(alignment: .bottom) {
                Image(systemName: "flame")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 75)
                    .foregroundStyle(.red)
                Image(systemName: "flame.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 75)
                    .foregroundStyle(.red)
                Text("\(currentStreak)")
                    .foregroundStyle(Color.background)
                    .font(.title.bold())
                    .padding(.bottom, 5)
                    .offset(y: -5)
            }
            VStack(alignment: .leading) {
                Text("\(currentStreak) semaine\(currentStreak > 1 ? "s" : "")")
                    .font(.largeTitle.bold())
                Text(streakTitle)
                    .font(.title2)
            }
            .foregroundStyle(Color.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.red.opacity(0.3))
        }
    }
    
    var streakTitle: String {
        switch currentStreak {
        case 0:
            return "C’est parti"

        case 1:
            return "Premier pas"

        case 2...3:
            return "Tu es lancé"

        case 4...6:
            return "Super début"

        case 7...11:
            return "Belle régularité"

        case 12...19:
            return "Tu es en forme"

        case 20...29:
            return "Très solide"

        case 30...49:
            return "Régularité exceptionnelle"

        case 50...99:
            return "Machine de constance"

        default:
            return "Légende vivante"
        }
    }
    
}

#Preview {
    StreakView(currentStreak: 33)
        .padding()
        .background(Color.background)
}
