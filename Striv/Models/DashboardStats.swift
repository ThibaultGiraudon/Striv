//
//  DashboardStats.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

struct DashboardStats {
    let weekly: [WeeklyStat]
    let global: GlobalStats
    let lastFourWeeks: GlobalStats
    let currentWeek: GlobalStats
    let currentStreak: Int
    let longestStreak: Int
    
    init(
        weekly: [WeeklyStat] = [],
        global: GlobalStats = .init(),
        lastFourWeeks: GlobalStats = .init(),
        currentWeek: GlobalStats = .init(),
        currentStreak: Int = 0,
        longestStreak: Int = 0
    ) {
        self.weekly = weekly
        self.global = global
        self.lastFourWeeks = lastFourWeeks
        self.currentWeek = currentWeek
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
    }
}
