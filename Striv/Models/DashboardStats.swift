//
//  DashboardStats.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

/// Represents all the aggregated statistics displayed on the dashboard.
///
/// `DashboardStats` centralizes multiple layers of statistics for a runner,
/// combining weekly and global metrics along with streak information.
/// This structure is primarily used by `DashboardViewModel` to display
/// a comprehensive overview of the user’s running performance.
///
/// Example use cases:
/// - Populating the dashboard UI
/// - Comparing weekly performance trends
/// - Showing streaks and cumulative totals
struct DashboardStats {
    
    /// Aggregated stats for each week, sorted chronologically.
    let weekly: [WeeklyStat]
    
    /// Aggregated stats for each month, sorted chronologically.
    let monthly: [MonthlyStat]
    
    /// Global statistics covering all workouts.
    let global: GlobalStats
    
    /// Statistics for the last four weeks, useful for short-term trend analysis.
    let lastFourWeeks: GlobalStats
    
    /// Statistics for the current week.
    let currentWeek: GlobalStats
    
    /// Current consecutive streak of weeks with at least one workout.
    let currentStreak: Int
    
    /// Longest consecutive streak of weeks with at least one workout.
    let longestStreak: Int
    
    /// Creates a new `DashboardStats`.
    ///
    /// - Parameters:
    ///   - weekly: Array of weekly statistics (default: empty array)
    ///   - global: Global statistics (default: `GlobalStats()` with zeros)
    ///   - lastFourWeeks: Aggregated stats for the last 4 weeks (default: `GlobalStats()`)
    ///   - currentWeek: Aggregated stats for the current week (default: `GlobalStats()`)
    ///   - currentStreak: Current consecutive active weeks (default: 0)
    ///   - longestStreak: Longest consecutive active weeks (default: 0)
    init(
        weekly: [WeeklyStat] = [],
        monthly: [MonthlyStat] = [],
        global: GlobalStats = .init(),
        lastFourWeeks: GlobalStats = .init(),
        currentWeek: GlobalStats = .init(),
        currentStreak: Int = 0,
        longestStreak: Int = 0
    ) {
        self.weekly = weekly
        self.monthly = monthly
        self.global = global
        self.lastFourWeeks = lastFourWeeks
        self.currentWeek = currentWeek
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
    }
}
