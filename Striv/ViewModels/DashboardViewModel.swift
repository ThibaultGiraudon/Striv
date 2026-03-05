//
//  DashboardViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published private(set) var stats: DashboardStats = .init()
    
    private let statisticsService: WorkoutStatisticsService
    
    init(statisticsService: WorkoutStatisticsService = .init()) {
        self.statisticsService = statisticsService
    }
    
    func load(with workouts: Workouts) {
        self.stats = statisticsService.computeDashboardStats(from: workouts)
    }
}
