//
//  WorkoutStatisticsService.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

final class WorkoutStatisticsService {
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
    
    func stats(for weeklyStats: [WeeklyStat]) -> GlobalStats {
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
    
    func lastFourWeeksStats(for weeklyStats: [WeeklyStat]) -> GlobalStats {
        self.stats(for: weeklyStats.suffix(4))
    }
    
    func currentWeekStats(for weeklyStats: [WeeklyStat]) -> GlobalStats {
        self.stats(for: weeklyStats.suffix(1))
    }
    
    func currentStreak(for weeklyStats: [WeeklyStat]) -> Int {
        var streak: Int = 0
        let sortedWeeks: [WeeklyStat] = weeklyStats.sorted { $0.startOfWeek > $1.startOfWeek }
        
        for week in sortedWeeks {
            if week.count > 0 {
                streak += 1
            } else {
                return streak
            }
        }
        
        return streak
    }
    
    func longestStreak(for weeklyStats: [WeeklyStat]) -> Int {
        var longestStreak: Int = 0
        var currentStreak: Int = 0
        let sortedWeeks: [WeeklyStat] = weeklyStats.sorted { $0.startOfWeek > $1.startOfWeek }
        
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
    
    func weeklyStats(for workouts: Workouts) -> [WeeklyStat] {
        guard let firstWeek = workouts
            .min(by: { $0.date < $1.date })?
            .date
            .firstDayOfWeek else {
            return []
        }

        var weeksStats: [WeeklyStat] = []
        
        let grouped = Dictionary(grouping: workouts) {
            $0.date.firstDayOfWeek
        }
        
        var currentWeek = Date().firstDayOfWeek
        
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
                    startOfWeek: startOfWeek,
                    distance: distance,
                    count: grouped[startOfWeek]?.count ?? 0,
                    duration: .init(duration),
                    elevation: elevation
                )
            )
            
            guard let previousWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek) else { break }
            currentWeek = previousWeek
        }
        
        return weeksStats.sorted(by: { $0.startOfWeek < $1.startOfWeek })
    }
    
    func computeDashboardStats(from workouts: [Workout]) -> DashboardStats {
        let weeklyStats = self.weeklyStats(for: workouts)
        let globalStats = self.globalStats(for: workouts)
        
        let lastFourWeeksStats = self.lastFourWeeksStats(for: weeklyStats)
        let currentWeekStats = self.currentWeekStats(for: weeklyStats)
        let longestStreak = self.longestStreak(for: weeklyStats)
        let currentStreak = self.currentStreak(for: weeklyStats)
        
        return DashboardStats(
            weekly: weeklyStats,
            global: globalStats,
            lastFourWeeks: lastFourWeeksStats,
            currentWeek: currentWeekStats,
            currentStreak: currentStreak,
            longestStreak: longestStreak
        )
    }
}
