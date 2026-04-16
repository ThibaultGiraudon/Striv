//
//  LastRunWidget.swift
//  StrivWidgetExtension
//
//  Created by Thibault Giraudon on 16/04/2026.
//

import WidgetKit
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

struct LastRunView : View {
    let entry: StrivEntry

    var body: some View {
            VStack(alignment: .leading) {
                Text(entry.data.lastRunDate.toString(format: "dd MMM. yyyy"))
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
        .onAppear {
            for familyName in UIFont.familyNames {
                print("\n-- \(familyName) \n")
                for fontName in UIFont.fontNames(forFamilyName: familyName) {
                    print(fontName)
                }
            }
        }
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
    StrivEntry(date: .now, data: WidgetData(
        weeklyGoal: 30,
        weeklyProgress: 0.5,
        lastRunDistance: 6.76,
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
