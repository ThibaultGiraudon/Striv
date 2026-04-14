//
//  StatsView.swift
//  Striv
//
//  Created by Thibault Giraudon on 24/02/2026.
//

import SwiftUI

struct StatsView: View {
    var title: String
    var stats: GlobalStats
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(), count: 2)) {
            statLabel(title: "Courses", value: "\(stats.count)")
            statLabel(title: "Temps", value: "\(stats.totalDuration.hours) h \(stats.totalDuration.hours < 100 ? "\(stats.totalDuration.minutes)" : "")")
            statLabel(title: "Dénivelé", value: "\(stats.totalElevation.roundedText(to: 0)) m")
            statLabel(title: "Moyenne", value: "\(stats.count > 0 ? (stats.totalDistance / Double(stats.count)).roundedText(to: 1) : "0") km")
        }
    }
    
    @ViewBuilder
    func statLabel(title: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 15) {
                Text(title)
                    .font(.title)
                Text(value)
                    .font(.title.bold())
            }
            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.customPrimary)
        }
    }
}

#Preview {
    StatsView(title: "All time", stats: .init(totalDistance: 21, totalDuration: .init(3600), totalElevation: 532, count: 1))
}
