//
//  StrivWidget.swift
//  StrivWidget
//
//  Created by Thibault Giraudon on 15/04/2026.
//

import WidgetKit
import SwiftUI
import StrivShared

// MARK: - Entry

struct StrivEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Provider

struct StrivProvider: TimelineProvider {
    
    private let suiteName = "group.striv"
    private let key = "widgetData"
    
    // MARK: Placeholder (widget gallery)
    
    func placeholder(in context: Context) -> StrivEntry {
        StrivEntry(date: Date(), data: mockData())
    }
    
    // MARK: Snapshot (preview / widget reload rapide)
    
    func getSnapshot(in context: Context, completion: @escaping (StrivEntry) -> Void) {
        let data = loadData() ?? mockData()
        let entry = StrivEntry(date: Date(), data: data)
        completion(entry)
    }
    
    // MARK: Timeline (le vrai cœur)
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StrivEntry>) -> Void) {
        let data: WidgetData

        if context.isPreview {
            data = mockData()
        } else {
            data = loadData() ?? mockData()
        }

        let entry = StrivEntry(date: Date(), data: data)

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!

        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Data Loading

private extension StrivProvider {
    
    func loadData() -> WidgetData? {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return nil
        }

        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(WidgetData.self, from: data)
        } catch {
            return nil
        }
    }
}

// MARK: - Mock Data (important pour preview + fallback)

private extension StrivProvider {
    
    func mockData() -> WidgetData {
        WidgetData(
            weeklyGoal: 30,
            weeklyProgress: 0,
            
            lastRunDistance: 0,
            lastRunDuration: "-",
            lastRunDate: Date.now,
            lastRunPace: "05\'46\"",
            
            streak: 0,
            
            prs: [
                PR(title: "5 km", value: "-", distance: 5000),
                PR(title: "10 km", value: "-", distance: 10000),
                PR(title: "Semi-marathon", value: "-", distance: 21097),
                PR(title: "Marathon", value: "-", distance: 42125)
                
            ]
        )
    }
}

struct DistanceView : View {
    let entry: StrivEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(entry.data.weeklyProgress, specifier: "%.1f") km")
                .font(.largeTitle.bold())
            
            Text("Distance semaine")
                .foregroundStyle(.secondary)
            
            Spacer()
            
            HStack {
                ProgressView(value: entry.data.weeklyProgress, total: Double(entry.data.weeklyGoal))
                    .tint(.teal)
                
                Text("\(entry.data.weeklyGoal) km")
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background {
                        Capsule()
                            .foregroundStyle(.quinary)
                    }
            }
        }
    }
}

struct DistanceWidget: Widget {
    let kind: String = "DistanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StrivProvider()
        ) { entry in
            DistanceView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Objectif hebdo")
        .description("Ta progression de course cette semaine")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DistanceWidget()
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
            PR(title: "5 km", value: "20:00", distance: 5000)
        ]
    ))
}
