//
//  WorkoutStatisticsService.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

/// Service responsible for computing statistics from workouts.
///
/// This service aggregates workout data to produce metrics
/// used across the application dashboard.
///
/// Responsibilities:
/// - Compute global statistics
/// - Generate weekly statistics
/// - Calculate running streaks
/// - Produce dashboard-ready metrics
///
/// The service is stateless and purely functional,
/// which makes it easy to test.
final class WorkoutStatisticsService {
    
    // MARK: - Stats
    
    /// Calculates all-time statistics from a collection of workouts.
    ///
    /// The following metrics are calculated:
    /// - Total distance
    /// - Total duration
    /// - Total elevation climbed
    /// - Number of runs
    ///
    /// - Parameter workouts: All workouts from which statistics are calculated.
    /// - Returns: A `GlobalStats` containing aggregated statistics.
    func globalStats(for workouts: Workouts) -> GlobalStats {
        
        var distance: Double = 0
        var duration: Int = 0
        var elevation: Double = 0
        
        for workout in workouts {
            distance += (workout.distance ?? 0) / 1000
            duration += workout.duration.totalSeconds
            elevation += workout.elevation ?? 0
        }
        
        return .init(
            totalDistance: distance,
            totalDuration: .init(duration),
            totalElevation: elevation,
            count: workouts.count
        )
    }
    
    /// Calculates aggregated statistics from weekly statistics.
    ///
    /// The following metrics are calculated:
    /// - Total distance
    /// - Total duration
    /// - Total elevation climbed
    /// - Number of runs
    ///
    /// - Parameter weeklyStats: An array of `WeeklyStat` representing
    ///   statistics for each week.
    /// - Returns: A `GlobalStats` representing the aggregated values
    ///   across the provided weeks.
    func stats(for weeklyStats: [PeriodicStat]) -> GlobalStats {
        var distance: Double = 0
        var duration: Int = 0
        var elevation: Double = 0
        var count: Int = 0
        
        for weekStat in weeklyStats {
            distance += weekStat.distance
            duration += weekStat.duration.totalSeconds
            elevation += weekStat.elevation
            count += weekStat.count
        }
        
        return .init(
            totalDistance: distance,
            totalDuration: .init(duration),
            totalElevation: elevation,
            count: count
        )
    }
    
    /// Calculates statistics for the last four weeks.
    ///
    /// - Parameter weeklyStats: An array of weekly statistics.
    /// - Returns: A `GlobalStats` containing aggregated values
    ///   for the last four weeks.
    func lastFourWeeksStats(for weeklyStats: [PeriodicStat]) -> GlobalStats {
        self.stats(for: weeklyStats.suffix(4))
    }
    
    /// Calculates statistics for the current week.
    ///
    /// - Parameter weeklyStats: An array of weekly statistics.
    /// - Returns: A `GlobalStats` containing aggregated values
    ///   for the current week.
    func currentWeekStats(for weeklyStats: [PeriodicStat]) -> GlobalStats {
        self.stats(for: weeklyStats.suffix(1))
    }
    
    /// Generates weekly statistics from a collection of workouts.
    ///
    /// Workouts are grouped by their start of week date.
    /// For each week, the following metrics are computed:
    /// - Total distance
    /// - Total duration
    /// - Total elevation
    /// - Number of runs
    ///
    /// Weeks without workouts are also included with zero values
    /// to ensure a continuous timeline.
    ///
    /// - Parameter workouts: The workouts used to compute weekly statistics.
    /// - Returns: An array of `WeeklyStat` sorted chronologically.
    func weeklyStats(for workouts: Workouts) -> [PeriodicStat] {
        guard let firstWeek = workouts
            .min(by: { $0.date < $1.date })?
            .date
            .firstDayOfWeek else {
            return []
        }

        var weeksStats: [PeriodicStat] = []
        
        let grouped = Dictionary(grouping: workouts) {
            $0.date.firstDayOfWeek
        }
        
        var currentWeek = Date().firstDayOfWeek
        
        guard firstWeek <= currentWeek else { return [] }
        
        while firstWeek <= currentWeek {
            let startOfWeek = currentWeek
            
            var distance: Double = 0
            var duration: Int = 0
            var elevation: Double = 0
            
            if let workouts = grouped[startOfWeek] {
                distance = workouts.reduce(0) { $0 + (($1.distance ?? 0) / 1000) }
                
                duration = workouts.reduce(0) {  $0 + $1.duration.totalSeconds }
                
                elevation = workouts.reduce(0) { $0 + ($1.elevation ?? 0) }
            }
            
            weeksStats.append(
                .init(
                    startDate: startOfWeek,
                    distance: distance,
                    count: grouped[startOfWeek]?.count ?? 0,
                    duration: .init(duration),
                    elevation: elevation
                )
            )
            
            guard let previousWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek) else { break }
            currentWeek = previousWeek
        }
        
        return weeksStats.sorted(by: { $0.startDate < $1.startDate })
    }
    
    func monthlyStats(for workouts: Workouts) -> [PeriodicStat] {
        guard let firstMonth = workouts
            .min(by: { $0.date < $1.date })?
            .date
            .firstDayOfMonth else {
            return []
        }
        
        var monthsStats: [PeriodicStat] = []

        let grouped = Dictionary(grouping: workouts) {
            $0.date.firstDayOfMonth
        }

        var currentMonth = Date().firstDayOfMonth

        while firstMonth <= currentMonth {
            let startOfMonth = currentMonth

            var distance: Double = 0
            var duration: Int = 0
            var elevation: Double = 0

            if let workouts = grouped[startOfMonth] {
                distance = workouts.reduce(0) { $0 + (($1.distance ?? 0) / 1000) }
                duration = workouts.reduce(0) { $0 + $1.duration.totalSeconds }
                elevation = workouts.reduce(0) { $0 + ($1.elevation ?? 0) }
            }
            
            monthsStats.append(
                .init(
                    startDate: startOfMonth,
                    distance: distance,
                    count: grouped[startOfMonth]?.count ?? 0,
                    duration: .init(duration),
                    elevation: elevation
                )
            )

            guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) else { break }
            currentMonth = previousMonth
        }

        return monthsStats
    }
    
    // MARK: - Streak
    
    /// Calculates the current running streak.
    ///
    /// The streak represents the number of consecutive weeks,
    /// starting from the most recent week, that contain at least one run.
    ///
    /// - Parameter weeklyStats: Weekly statistics used to determine the streak.
    /// - Returns: The number of consecutive active weeks.
    func currentStreak(for weeklyStats: [PeriodicStat]) -> Int {
        var streak: Int = 0
        let sortedWeeks: [PeriodicStat] = weeklyStats.sorted { $0.startDate > $1.startDate }
        var isFirstWeek: Bool = true
        
        for week in sortedWeeks {
            if isFirstWeek && week.count == 0 {
                continue
            }
            isFirstWeek = false
            if week.count > 0 {
                streak += 1
            } else {
                return streak
            }
        }
        
        return streak
    }
    
    /// Calculates the longest running streak.
    ///
    /// The longest streak represents the maximum number of
    /// consecutive weeks containing at least one run.
    ///
    /// - Parameter weeklyStats: Weekly statistics used to compute the streak.
    /// - Returns: The length of the longest streak in weeks.
    func longestStreak(for weeklyStats: [PeriodicStat]) -> Int {
        var longestStreak: Int = 0
        var currentStreak: Int = 0
        let sortedWeeks: [PeriodicStat] = weeklyStats.sorted { $0.startDate > $1.startDate }
        
        for week in sortedWeeks {
            if week.count > 0 {
                currentStreak += 1
            } else {
                if currentStreak >= longestStreak {
                    longestStreak = currentStreak
                }
                currentStreak = 0
            }
        }
        
        return longestStreak > currentStreak ? longestStreak : currentStreak
    }
    
    // MARK: - Dashboard
    
    /// Computes all statistics required for the dashboard.
    ///
    /// This method aggregates workouts into weekly statistics,
    /// calculates global statistics, recent statistics, and running streaks.
    ///
    /// - Parameter workouts: The workouts used to compute dashboard statistics.
    /// - Returns: A `DashboardStats` containing all metrics used by the dashboard.
    func computeDashboardStats(from workouts: [Workout]) -> DashboardStats {
        let weeklyStats = self.weeklyStats(for: workouts)
        let monthlyStats = self.monthlyStats(for: workouts)
        let globalStats = self.globalStats(for: workouts)
        
        let lastFourWeeksStats = self.lastFourWeeksStats(for: weeklyStats)
        let currentWeekStats = self.currentWeekStats(for: weeklyStats)
        let currentMonthStats = self.stats(for: monthlyStats.filter({ $0.startDate == Date().firstDayOfMonth }))
        let currentYearStats = self.stats(for: monthlyStats.filter( {$0.startDate >= Date().firstDayOfYear }))
        let longestStreak = self.longestStreak(for: weeklyStats)
        let currentStreak = self.currentStreak(for: weeklyStats)
        
        return DashboardStats(
            weekly: weeklyStats,
            monthly: monthlyStats,
            global: globalStats,
            lastFourWeeks: lastFourWeeksStats,
            currentWeek: currentWeekStats,
            currentMonth: currentMonthStats,
            currentYear: currentYearStats,
            currentStreak: currentStreak,
            longestStreak: longestStreak
        )
    }
}
