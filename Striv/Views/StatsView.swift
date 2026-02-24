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
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
            VStack(spacing: 10) {
                statLabel(
                    title: "Number of run",
                    value: "\(stats.count)")
                statLabel(
                    title: "Distance",
                    value: stats.totalDistance)
                statLabel(
                    title: "Time",
                    value: stats.totalDuration.label)
                statLabel(
                    title: "Elevation",
                    value: stats.totalElevation)
            }
            .font(.title2)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.customPrimary)
            }
        }
    }
    
    @ViewBuilder
    func statLabel(title: String, value: StatDisplayable) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value.statText)
        }
    }
}

#Preview {
    StatsView(title: "All time", stats: .init(totalDistance: 21, totalDuration: .init(3600), totalElevation: 532, count: 1))
}
