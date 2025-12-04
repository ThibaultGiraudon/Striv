//
//  RunRowView.swift
//  Striv
//
//  Created by Thibault Giraudon on 04/12/2025.
//

import SwiftUI

extension Date {
    /// Converts a `Date` to `String`
    ///
    /// - Parameter format: A `String` representing the format into converts the date.
    /// - Returns: A `String` equal at the initial date.
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return dateFormatter.string(from: self)
    }
}

struct RunRowView: View {
    var workout: Workout
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(workout.date.toString(format: "dd MMM. YYYY"))
                .foregroundStyle(.secondary)
            Text("\((workout.distance ?? 0.0)/1000, specifier: "%.2f" ) km")
                .font(.switzer(size: 36, weight: .bold))
                .italic()
                .foregroundStyle(.primaryText)
            HStack {
                Image(systemName: "clock")
                Text("\(workout.duration.hours):\(workout.duration.minutes):\(workout.duration.seconds)")
                Spacer()
                Image(systemName: "figure.run")
                    .foregroundStyle(.teal)
                Text("\(workout.pace.minutes)\'\(workout.pace.seconds)\"/km")
            }
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    RunRowView(workout: Workout(date: .now, distance: 12129, duration: .init(4333), hr: 171, kcal: 949, elevation: 275))
}
