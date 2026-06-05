//
//  LastRunWidget.swift
//  StrivWidgetExtension
//
//  Created by Thibault Giraudon on 16/04/2026.
//

import WidgetKit
import SwiftUI
import StrivShared

struct LastRunView : View {
    let entry: StrivEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.data.lastRunDate.formatted(format: "dd MMM. yyyy"))
                .foregroundStyle(.secondary)
                .font(.title3)
            Text("\(entry.data.lastRunDistance/1000, specifier: "%.2f") km")
                .font(.switzer(size: 40, weight: .bold))
                .italic()
                .padding(.bottom, 4)
            HStack {
                Image(systemName: "clock")
                Text(entry.data.lastRunDuration)
                Spacer()
                Image(systemName: "figure.run")
                Text(entry.data.lastRunPace)
                
            }
            .font(.title3)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label())
    }
    
    func label() -> String {
        var labels: [String] = []
        
        labels.append(entry.data.voiceOverLabels.date)
        
        labels.append("\(entry.data.voiceOverLabels.distance) km")
        
        labels.append("en \(entry.data.voiceOverLabels.duration)")
        
        labels.append("rythme: \(entry.data.voiceOverLabels.pace) par km")
        
        return labels.joined(separator: ", ")
    }
}

extension Double {
    func roundedText(to numbers: Int) -> String {
        String(format: "%.\(numbers)f", self)
    }
}

struct LastRunWidget: Widget {
    let kind: String = "LastRunWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StrivProvider()
        ) { entry in
            LastRunView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("PRs")
        .description("Tes records personnels")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    LastRunWidget()
} timeline: {
    StrivEntry(date: Date.now, data: WidgetData(
        weeklyGoal: 30,
        weeklyProgress: 0.5,
        lastRunDistance: 6.76,
        lastRunDuration: "25:00",
        lastRunDate: .now,
        lastRunPace: "05\'46\"",
        voiceOverLabels: .init(distance: "", duration: "", date: "", pace: ""),
        streak: 3,
        prs: [
            PR(title: "5 km", value: "22min38", distance: 5000),
            PR(title: "10 km", value: "48min52", distance: 10000),
            PR(title: "Semi-marathon", value: "02h08min37", distance: 21097),
            PR(title: "Marathon", value: "05h14min56", distance: 42125),
        ]
    ))
}
