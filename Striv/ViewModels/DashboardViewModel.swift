//
//  DashboardViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation
import Combine

/// ViewModel responsible for preparing dashboard statistics.
///
/// `DashboardViewModel` transforms raw workout data into
/// aggregated statistics used by the dashboard views.
///
/// It relies on `WorkoutStatisticsService` to compute
/// all metrics such as:
/// - Global statistics
/// - Weekly statistics
/// - Current week metrics
/// - Last four weeks metrics
/// - Running streaks
///
/// The computed statistics are exposed through the `stats`
/// published property so SwiftUI views can reactively update.
class DashboardViewModel: ObservableObject {
    
    /// Aggregated statistics used by the dashboard UI.
    ///
    /// This property is updated whenever new workouts are loaded.
    @Published private(set) var stats: DashboardStats = .init()
    
    /// Service responsible for computing workout statistics.
    private let statisticsService: WorkoutStatisticsService
    
    /// Creates a new `DashboardViewModel`.
    ///
    /// - Parameter statisticsService: The service used to compute
    ///   workout statistics. A default instance is provided for
    ///   convenience but can be injected for testing.
    init(statisticsService: WorkoutStatisticsService = .init()) {
        self.statisticsService = statisticsService
    }
    
    /// Loads workouts and computes the dashboard statistics.
    ///
    /// The workouts are passed to `WorkoutStatisticsService`
    /// which generates all the aggregated metrics required
    /// by the dashboard.
    ///
    /// - Parameter workouts: The workouts used to compute
    ///   dashboard statistics.
    func load(with workouts: Workouts) {
        self.stats = statisticsService.computeDashboardStats(from: workouts)
    }
}
