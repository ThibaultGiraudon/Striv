//
//  HealthKit+metrics.swift
//  Striv
//
//  Created by Thibault Giraudon on 23/04/2026.
//

import Foundation
import HealthKit

extension HealthKitHelper {
    
    func fetchActiveEnergy(with id: UUID) async throws -> Double? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchActiveEnergy(for: hkWorkout)
    }
    
    func fetchActiveEnergy(for workout: HKWorkout) async throws -> Double? {
        try await fetchQuantity(
            for: workout,
            identifier: .activeEnergyBurned,
            options: .cumulativeSum,
            unit: .kilocalorie()
        )
    }
    
    func fetchAverageHeartRate(with id: UUID) async throws -> Double? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchAverageHeartRate(for: hkWorkout)
    }
    
    func fetchAverageHeartRate(for workout: HKWorkout) async throws -> Double? {
        try await fetchQuantity(
            for: workout,
            identifier: .heartRate,
            options: .discreteAverage,
            unit: HKUnit(from: "count/min")
        )
    }
    
    func fetchDistance(with id: UUID) async throws -> Double? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchDistance(for: hkWorkout)
    }
    
    func fetchDistance(for workout: HKWorkout) async throws -> Double? {
        try await fetchQuantity(
            for: workout,
            identifier: .distanceWalkingRunning,
            options: .cumulativeSum,
            unit: .meter()
        )
    }
    
    func fetchPower(with id: UUID) async throws -> Double? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchPower(for: hkWorkout)
    }
    
    func fetchPower(for workout: HKWorkout) async throws -> Double? {
        try await fetchQuantity(
            for: workout,
            identifier: .runningPower,
            options: .discreteAverage,
            unit: .watt()
        )
    }
    
    func fetchCadence(with id: UUID) async throws -> Double? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchCadence(for: hkWorkout)
    }
    
    func fetchCadence(for workout: HKWorkout) async throws -> Double? {
        try await fetchQuantity(
            for: workout,
            identifier: .stepCount,
            options: .cumulativeSum,
            unit: .count()
        )
    }
    
    func fetchRunSamples(with id: UUID) async throws -> [RunSample]? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchRunSamples(for: hkWorkout)
    }
    
    func fetchRunSamples(for workout: HKWorkout) async throws -> [RunSample] {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            throw HealthKitError.invalidType
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )

        let startDate = workout.startDate
        let endDate = workout.endDate

        return try await withCheckedThrowingContinuation { continuation in

            let query = HKStatisticsCollectionQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: startDate,
                intervalComponents: DateComponents(second: 2)
            )

            query.initialResultsHandler = { _, results, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results else {
                    continuation.resume(returning: [])
                    return
                }

                var samples: [RunSample] = []
                var runningTotal: Double = 0

                results.enumerateStatistics(from: startDate, to: endDate) { stat, _ in

                    let value = stat.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                    runningTotal += value

                    let time = stat.startDate.timeIntervalSince(startDate)

                    samples.append(
                        RunSample(
                            distance: runningTotal,
                            time: time
                        )
                    )
                }

                continuation.resume(returning: samples)
            }

            healthStore.execute(query)
        }
    }
}
