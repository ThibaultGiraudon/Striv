//
//  StatsCard.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI

struct StatsCard: View {
    let workout: Workout
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(), count: 2)) {
            StatRowView(systemImage: "clock.fill", title: "Temps", value: workout.duration.label, metric: .time)
            StatRowView(systemImage: "figure.run", title: "Rythme", value: workout.pace.shortLabel, metric: .pace)
            StatRowView(systemImage: "suit.heart.fill", title: "Fréquence", value: workout.hr, metric: .heartRate)
            StatRowView(systemImage: "flame.fill", title: "Calorie", value: workout.kcal, metric: .calories)
            StatRowView(systemImage: "mountain.2.fill", title: "Dénivelé", value: workout.elevation, metric: .elevation)
            StatRowView(systemImage: "bolt.fill", title: "Puissance", value: workout.power, metric: .power)
            StatRowView(systemImage: "shoeprints.fill", title: "Cadence", value: workout.cadence, metric: .cadence)
        }
        .cardStyle()
    }
}
