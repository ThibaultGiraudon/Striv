//
//  ElevationCard.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI

struct ElevationCard: View {
    let workout: Workout
    @ObservedObject var workoutDetailVM: WorkoutDetailViewModel
    
    var body: some View {
        if let elevationSeries = workoutDetailVM.elevationSeries, let minElevation = workoutDetailVM.minElevation, let maxElevation = workoutDetailVM.maxElevation {
            VStack {
                HStack {
                    Text("Dénivelé")
                    Spacer()
                }
                .font(.title2.bold())
                
                MetricsCharts(series: elevationSeries)
                LazyVGrid(columns: Array(repeating: .init(), count: 2)) {
                    StatRowView(systemImage: "mountain.2.fill", title: "Dénivelé +", value: workout.elevation, metric: .elevation)
                    StatRowView(systemImage: "mountain.2.fill", title: "Altitude max.", value: maxElevation, metric: .elevation)
                    StatRowView(systemImage: "mountain.2.fill", title: "Altitude min.", value: minElevation, metric: .elevation)
                }
            }
            .cardStyle()
        }
    }
}
