//
//  ChallengeView.swift
//  Striv
//
//  Created by Thibault Giraudon on 18/03/2026.
//

import SwiftUI
import SwiftData

struct ChallengesView: View {
    @StateObject private var challengeVM = ChallengeViewModel()
    @Query(sort: [SortDescriptor(\Workout.date, order: .reverse)]) private var workouts: Workouts
    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: .init(), count: 3)) {
                ForEach(challengeVM.challenges) { challenge in
                    VStack(alignment: .center) {
                        Image(systemName: "figure.run.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(challenge.isCompleted ? .customPink : .gray)
                        Text(challenge.title)
                        ProgressView(value: challenge.progression, total: 1.0)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            challengeVM.updateAllChallenges(with: workouts)
        }
    }
}

#Preview {
    ChallengesView()
}
