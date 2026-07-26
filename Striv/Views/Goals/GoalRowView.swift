//
//  GoalRowView.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI

struct GoalRowView: View {
    let goal: Goal?
    let distance: PresetDistance
    let pace: Pace?
    let color: Color = .teal
    init(goal: Goal?, distance: PresetDistance) {
        self.goal = goal
        if let goal {
            self.pace = Pace(pace: goal.time / (goal.distance.meters / 1_000))
        } else {
            self.pace = nil
        }
        self.distance = distance
    }
    
    var body: some View {
        HStack {
            Image(systemName: "figure.run")
                .font(.title)
                .foregroundStyle(color)
                .padding(10)
                .background {
                    Circle()
                        .foregroundStyle(color.opacity(0.3))
                }
            
            VStack(alignment: .leading) {
                Text("\(distance.title)")
                    .font(.title2.bold())
                if let pace {
                    HStack {
                        Text("Allure: ")
                        Text(pace.shortLabel)
                            .foregroundStyle(color)
                    }
                }
            }
            
            Spacer()
            if let goal {
                Text(Duration(goal.time * 60).shortLabel)
                    .font(.title2.bold())
            }
            Image(systemName: "chevron.right")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
        .foregroundStyle(.primaryText)
    }
}

#Preview {
    GoalRowView(goal: .init(distance: .halfMarathon, time: 120, isMain: true), distance: .halfMarathon)
}
