//
//  MainGoalView.swift
//  Striv
//
//  Created by Thibault Giraudon on 26/07/2026.
//

import SwiftUI

struct MainGoalView: View {
    let mainGoal: Goal
    var pace: Pace {
        Pace(pace: mainGoal.time / (mainGoal.distance.meters / 1_000))
    }
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(.customPink)
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text("\(mainGoal.distance.title)")
                    .font(.title2.bold())
                HStack {
                    Text("Allure: ")
                    Text(pace.shortLabel)
                        .foregroundStyle(.customPink)
                }
            }
            
            Spacer()
            
            Text(Duration(mainGoal.time * 60).shortLabel)
                .font(.title2.bold())
            
            Image(systemName: "chevron.right")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
        .foregroundStyle(.primaryText)
    }
}

#Preview {
    MainGoalView(mainGoal: .init(distance: .halfMarathon, time: 120, isMain: true))
}
