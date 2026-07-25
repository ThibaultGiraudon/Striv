//
//  PaceCard.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI

struct PaceCard: View {
    let workout: Workout
    @ObservedObject var workoutDetailVM: WorkoutDetailViewModel
    var body: some View {
        if let paceSeries = workoutDetailVM.paceSeries, let bestSplit = workoutDetailVM.bestSplit {
            VStack {
                HStack {
                    Text("Allure")
                    Spacer()
                }
                .font(.title2.bold())
                
                PaceCharts(series: paceSeries)
                LazyVGrid(columns: Array(repeating: .init(), count: 2)) {
                    StatRowView(systemImage: "figure.run", title: "Allure moy.", value: workout.pace.shortLabel, metric: .pace)
                    StatRowView(systemImage: "figure.run", title: "Meilleur km", value: bestSplit.shortLabel, metric: .pace)
                }
            }
            .cardStyle()
        }
    }
}
