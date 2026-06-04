//
//  HealthKitHelper.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation
import HealthKit
import CoreLocation


protocol HealthKitHelperInterface {
    func requestAuthorization() async throws
    func syncWorkouts() async throws -> ([WorkoutData], [UUID])
    func fetchCoordinates(with id: UUID) async throws -> [CLLocation]
    func fetchActiveEnergy(with id: UUID) async throws -> Double?
    func fetchAverageHeartRate(with id: UUID) async throws -> Double?
    func fetchDistance(with id: UUID) async throws -> Double?
    func fetchPower(with id: UUID) async throws -> Double?
    func fetchCadence(with id: UUID) async throws -> Double?
    func fetchRunSamples(with id: UUID) async throws -> [RunSample]
}

/// Helper responsible for interacting with HealthKit.
///
/// `HealthKitHelper` provides a simplified interface to query
/// running workouts and related metrics from HealthKit.
///
/// Responsibilities:
/// - Request HealthKit authorization
/// - Fetch running workouts
/// - Synchronize workouts using anchored queries
/// - Retrieve workout metrics (distance, heart rate, power, etc.)
/// - Retrieve workout routes and coordinates
///
/// This helper is implemented as a shared singleton because
/// HealthKit interactions rely on a single `HKHealthStore` instance.
actor HealthKitHelper: HealthKitHelperInterface {
    
    // MARK: - Properties
    
    let healthStore = HKHealthStore()
    let anchorKey = "healthkit.workout.anchor"
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        let types: [HKObjectType] = [
            .workoutType(),
            .activitySummaryType(),
            HKSeriesType.workoutRoute(),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKQuantityType.quantityType(forIdentifier: .runningPower),
            HKQuantityType.quantityType(forIdentifier: .stepCount)
        ].compactMap { $0 }
        
        try await healthStore.requestAuthorization(toShare: [], read: Set(types))
    }
}
