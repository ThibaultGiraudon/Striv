//
//  WeeklyStat.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

/// Represents aggregated statistics for a single week.
///
/// `WeeklyStat` is used to summarize a runner’s weekly performance,
/// including distance, duration, elevation, and number of workouts.
/// This structure is primarily used by `WorkoutStatisticsService`
/// to compute streaks, weekly charts, and dashboard metrics.
struct PeriodicStat: Identifiable, Hashable {
    
    /// Unique identifier for the week statistic.
    var id = UUID()
    
    /// The start date of the week.
    let startDate: Date
    
    /// The end date of the week (6 days after `startOfWeek`).
    var endOfWeek: Date {
        startDate.addingTimeInterval(3600 * 24 * 6)
    }
    
    /// A readable label for the week, e.g., "10 Mar-16 Mar".
    var label: String {
        startDate.formatted(format: "d MMMM") + " - " + endOfWeek.formatted(format: "d MMMM")
    }
    
    /// Total distance run in meters during the week.
    let distance: Double
    
    /// Number of workouts performed in the week.
    let count: Int
    
    /// Total duration of workouts in the week.
    let duration: Duration
    
    /// Total elevation climbed during the week.
    let elevation: Double
    
    /// Creates a new `WeeklyStat`.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (default: new UUID)
    ///   - startOfWeek: Start date of the week (default: current date)
    ///   - distance: Total distance in meters (default: 0)
    ///   - count: Number of workouts (default: 0)
    ///   - duration: Total duration of workouts (default: 0 seconds)
    ///   - elevation: Total elevation climbed (default: 0 meters)
    init(
        id: UUID = UUID(),
        startDate: Date = .now,
        distance: Double = 0.0,
        count: Int = 0,
        duration: Duration = .init(0),
        elevation: Double = 0.0
    ) {
        self.id = id
        self.startDate = startDate
        self.distance = distance
        self.count = count
        self.duration = duration
        self.elevation = elevation
    }
}
