//
//  GlobalStats.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

/// Represents aggregated statistics across all workouts.
///
/// `GlobalStats` is used to summarize a runner’s overall performance,
/// typically displayed in dashboards or summary views.
/// It includes metrics such as total distance, total duration, elevation climbed,
/// and the number of workouts performed.
///
/// Example use cases:
/// - Displaying cumulative stats on the dashboard
/// - Comparing global performance over time
/// - Feeding analytics or graphs with totals
struct GlobalStats {
    
    /// Total distance covered across all workouts (in kilometers or meters, depending on your app convention).
    let totalDistance: Double
    
    /// Total duration of all workouts.
    let totalDuration: Duration
    
    /// Total elevation climbed across all workouts (in meters).
    let totalElevation: Double
    
    /// Total number of workouts included in the aggregation.
    let count: Int
    
    /// Creates a new `GlobalStats`.
    ///
    /// - Parameters:
    ///   - totalDistance: Total distance (default: 0.0)
    ///   - totalDuration: Total duration (default: 0 seconds)
    ///   - totalElevation: Total elevation climbed (default: 0.0)
    ///   - count: Number of workouts (default: 0)
    init(
        totalDistance: Double = 0.0,
        totalDuration: Duration = .init(0),
        totalElevation: Double = 0.0,
        count: Int = 0
    ) {
        self.totalDistance = totalDistance
        self.totalDuration = totalDuration
        self.totalElevation = totalElevation
        self.count = count
    }
}
