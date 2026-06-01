//
//  RunRowView.swift
//  Striv
//
//  Created by Thibault Giraudon on 04/12/2025.
//

import SwiftUI

struct RunRowView: View {
    var workout: Workout
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(workout.date.formatted(format: "dd MMMM YYYY"))
                .foregroundStyle(.secondary)
            Text("\((workout.distance ?? 0.0)/1000, specifier: "%.2f") km")
                .font(.switzer(size: 36, weight: .bold))
                .italic()
                .foregroundStyle(.primaryText)
            HStack {
                Image(systemName: "clock")
                Text(workout.duration.label)
                Spacer()
                Image(systemName: "figure.run")
                    .foregroundStyle(.customPink)
                Text(workout.pace.label)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label())
    }
    
    func label() -> String {
        var labels: [String] = []
        
        labels.append(workout.date.formatted(format: "dd MMMM YYYY"))
        
        labels.append("\(((workout.distance ?? 0.0)/1000).roundedText(to: 2)) km")
        
        labels.append("en \(workout.duration.voiceOverLabel)")
        
        labels.append("rythme: \(workout.pace.shortLabel) par km")
        
        return labels.joined(separator: ", ")
    }
}

#Preview {
    RunRowView(workout: Workout(id: UUID(), date: .now, distance: 12129, duration: .init(4333), hr: 171, kcal: 949, elevation: 275, coordinates: [], altitudes: []))
}
