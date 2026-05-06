//
//  WorkoutStatisticsServiceTests.swift
//  Striv
//
//  Created by Thibault Giraudon on 27/04/2026.
//


import XCTest
@testable import Striv

final class WorkoutStatisticsServiceTests: XCTestCase {
    
    var service: WorkoutStatisticsService!
    
    override func setUp() {
        super.setUp()
        service = WorkoutStatisticsService()
    }
    
    // MARK: - Helpers
    
    func makeWorkout(
        distance: Double,
        duration: Int,
        elevation: Double,
        date: Date
    ) -> Workout {
        let workout = Workout.mock()
        workout.distance = distance
        workout.duration = .init(duration)
        workout.elevation = elevation
        workout.date = date
        return workout
    }
    
    // MARK: - Global Stats
    
    func test_globalStats_shouldAggregateCorrectly() {
        // GIVEN
        let workouts = [
            makeWorkout(distance: 5000, duration: 1500, elevation: 100, date: Date()),
            makeWorkout(distance: 10000, duration: 3000, elevation: 200, date: Date())
        ]
        
        // WHEN
        let stats = service.globalStats(for: workouts)
        
        // THEN
        XCTAssertEqual(stats.totalDistance, 15) // km
        XCTAssertEqual(stats.totalDuration.totalSeconds, 4500)
        XCTAssertEqual(stats.totalElevation, 300)
        XCTAssertEqual(stats.count, 2)
    }
    
    // MARK: - Weekly Stats
    
    func test_weeklyStats_shouldGroupByWeek() {
        // GIVEN
        let calendar = Calendar.current
        let now = Date()
        let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
        
        let workouts = [
            makeWorkout(distance: 5000, duration: 1500, elevation: 100, date: now),
            makeWorkout(distance: 5000, duration: 1500, elevation: 100, date: lastWeek)
        ]
        
        // WHEN
        let stats = service.weeklyStats(for: workouts)
        
        // THEN
        XCTAssertGreaterThanOrEqual(stats.count, 2)
        XCTAssertTrue(stats.contains(where: { $0.count == 1 }))
    }
    
    // MARK: - Monthly Stats
    
    func test_monthlyStats_shouldCalculateDistanceChange() {
        // GIVEN
        let calendar = Calendar.current
        let now = Date()
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
        
        let workouts = [
            makeWorkout(distance: 10000, duration: 3000, elevation: 100, date: lastMonth),
            makeWorkout(distance: 20000, duration: 6000, elevation: 200, date: now)
        ]
        
        // WHEN
        let stats = service.monthlyStats(for: workouts)
        
        // THEN
        XCTAssertEqual(stats.count, 2)
        XCTAssertEqual(stats.first?.distance, 10)
        XCTAssertNil(stats.first?.distanceChange)
    }
    
    // MARK: - Streak
    
    func test_currentStreak_shouldStopAtFirstEmptyWeek() {
        // GIVEN
        let weeks = [
            WeeklyStat(startOfWeek: Date(), distance: 10, count: 1, duration: Duration(1000), elevation: 100),
            WeeklyStat(startOfWeek: Date().addingTimeInterval(-604800), distance: 0, count: 0, duration: Duration(0), elevation: 0),
            WeeklyStat(startOfWeek: Date().addingTimeInterval(-1209600), distance: 10, count: 1, duration: Duration(1000), elevation: 100)
        ]
        
        // WHEN
        let streak = service.currentStreak(for: weeks)
        
        // THEN
        XCTAssertEqual(streak, 1)
    }
    
    func test_longestStreak_shouldReturnMaxSequence() {
        // GIVEN
        let weeks = [
            WeeklyStat(startOfWeek: Date(), distance: 10, count: 1, duration: Duration(1000), elevation: 100),
            WeeklyStat(startOfWeek: Date().addingTimeInterval(-604800), distance: 10, count: 1, duration: Duration(1000), elevation: 100),
            WeeklyStat(startOfWeek: Date().addingTimeInterval(-1209600), distance: 0, count: 0, duration: Duration(0), elevation: 0),
            WeeklyStat(startOfWeek: Date().addingTimeInterval(-1814400), distance: 10, count: 1, duration: Duration(1000), elevation: 100)
        ]
        
        // WHEN
        let streak = service.longestStreak(for: weeks)
        
        // THEN
        XCTAssertEqual(streak, 2)
    }
    
    // MARK: - Dashboard
    
    func test_computeDashboardStats_shouldReturnConsistentData() {
        // GIVEN
        let workouts = [
            makeWorkout(distance: 5000, duration: 1500, elevation: 100, date: Date()),
            makeWorkout(distance: 10000, duration: 3000, elevation: 200, date: Date())
        ]
        
        // WHEN
        let dashboard = service.computeDashboardStats(from: workouts)
        
        // THEN
        XCTAssertEqual(dashboard.global.count, 2)
        XCTAssertFalse(dashboard.weekly.isEmpty)
        XCTAssertFalse(dashboard.monthly.isEmpty)
    }
}
