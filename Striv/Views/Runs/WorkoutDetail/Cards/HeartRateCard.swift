//
//  HeartRateCard.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI

struct HeartRateCard: View {
    let workout: Workout
    @ObservedObject var workoutDetailVM: WorkoutDetailViewModel
    var body: some View {
        if let hrSeries = workoutDetailVM.heartRateSeries, let maxHr = workoutDetailVM.maxHeartRate {
            VStack {
                HStack {
                    Text("Fréquence cardiaque")
                    Spacer()
                }
                .font(.title2.bold())
                
                MetricsCharts(series: hrSeries)
                LazyVGrid(columns: Array(repeating: .init(), count: 2)) {
                    StatRowView(systemImage: "suit.heart.fill", title: "FC moy.", value: workout.hr, metric: .heartRate)
                    StatRowView(systemImage: "figure.run", title: "FC max.", value: maxHr, metric: .heartRate)
                }
            }
            .cardStyle()
        }
    }
}
