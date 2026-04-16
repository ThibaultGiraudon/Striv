//
//  PRsWidget.swift
//  StrivWidgetExtension
//
//  Created by Thibault Giraudon on 16/04/2026.
//

import WidgetKit
import SwiftUI

struct PRsView : View {
    let entry: StrivEntry

    var body: some View {
        let sortedPRs = entry.data.prs.sorted(by: {$0.distance < $1.distance})
        VStack {
            ForEach(sortedPRs, id: \.self) { pr in
                HStack {
                    Text(pr.title)
                    Spacer()
                    Text(pr.value)
                        .font(.title3.bold())
                }
                if pr != sortedPRs.last {
                    Divider()
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
}

struct PRsWidget: Widget {
    let kind: String = "PRsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StrivProvider()
        ) { entry in
            PRsView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("PRs")
        .description("Tes records personnels")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    PRsWidget()
} timeline: {
    StrivEntry(date: .now, data: WidgetData(
        weeklyGoal: 30,
        weeklyProgress: 0.5,
        lastRunDistance: 5,
        lastRunDuration: "25:00",
        lastRunDate: .now,
        lastRunPace: "05\'46\"",
        streak: 3,
        prs: [
            PR(title: "5 km", value: "22min38", distance: 5000),
            PR(title: "10 km", value: "48min52", distance: 10000),
            PR(title: "Semi-marathon", value: "02h08min37", distance: 21097),
            PR(title: "Marathon", value: "05h14min56", distance: 42125),
        ]
    ))
}
