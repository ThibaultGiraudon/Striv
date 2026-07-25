//
//  PowerCard.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI

struct PowerCard: View {
    let workout: Workout
    @ObservedObject var workoutDetailVM: WorkoutDetailViewModel
    
    var body: some View {
        if let powerSeries = workoutDetailVM.powerSeries {
            VStack {
                HStack {
                    Text("Puissance")
                    Spacer()
                }
                .font(.title2.bold())
                
                MetricsCharts(series: powerSeries)
                HStack {
                    StatRowView(systemImage: "bolt.fill", title: "Puissance", value: workout.power, metric: .power)
                    Spacer()
                }
            }
            .cardStyle()
        }
    }
}
