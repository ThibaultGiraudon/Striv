//
//  StreakWidget.swift
//  StrivWidgetExtension
//
//  Created by Thibault Giraudon on 16/04/2026.
//

import WidgetKit
import SwiftUI
import StrivShared

struct StreakView : View {
    let entry: StrivEntry

    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Image(systemName: "flame.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.red)
                
                Image(systemName: "flame")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.red)
                
                Text("\(entry.data.streak)")
                    .font(.system(size: 40, weight: .bold))
                    .blendMode(.destinationOut)
                    .offset(y: 15)
            }
            .compositingGroup()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tu as réalisé une chaine de \(entry.data.streak) semaines")
    }
}

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StrivProvider()
        ) { entry in
            StreakView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Streak")
        .description("Ton nombre de semaines d'activités consécutives")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    StreakWidget()
} timeline: {
    StrivEntry(date: .now, data: WidgetData(
        weeklyGoal: 30,
        weeklyProgress: 0.5,
        lastRunDistance: 5,
        lastRunDuration: "25:00",
        lastRunDate: .now,
        lastRunPace: "05\'46\"",
        voiceOverLabels: .init(distance: "", duration: "", date: "", pace: ""),
        streak: 333,
        prs: [
            PR(title: "5 km", value: "20:00", distance: 5000)
        ]
    ))
}
