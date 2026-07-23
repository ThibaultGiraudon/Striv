//
//  HealthKit+workouts.swift
//  Striv
//
//  Created by Thibault Giraudon on 23/04/2026.
//

import Foundation
import HealthKit

extension HealthKitHelper {
    
    /// Fetches a specific workout from HealthKit using its identifier.
    ///
    /// - Parameter id: The unique identifier of the workout.
    /// - Returns: The corresponding `HKWorkout`.
    /// - Throws: An error if the workout cannot be found or the query fails.
    func getWorkout(with id: UUID) async throws -> HKWorkout {        
        let predicate = HKQuery.predicateForObject(with: id)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: 1,
                sortDescriptors: nil
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let workout = samples?.first as? HKWorkout else {
                    continuation.resume(throwing: NSError())
                    return
                }

                continuation.resume(returning: workout)
            }

            healthStore.execute(query)
        }
    }
    
    func syncWorkouts() async throws -> ([WorkoutData], [UUID]) {
        let anchor = getAnchor()
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        
        let response: ([HKWorkout], [UUID], HKQueryAnchor) = try await withCheckedThrowingContinuation { continuation in
            let query = HKAnchoredObjectQuery(
                type: .workoutType(),
                predicate: predicate,
                anchor: anchor,
                limit: HKObjectQueryNoLimit
            ) { _, samples, deleted, newAnchor, error in
                
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let newAnchor else {
                    continuation.resume(throwing: HealthKitError.noDataOrNoPermission)
                    return
                }
                
                guard let workouts = samples as? [HKWorkout], !workouts.isEmpty else {
                    continuation.resume(throwing: HealthKitError.noDataOrNoPermission)
                    return
                }
                
                let deletedIds = deleted?.map(\.uuid) ?? []

                continuation.resume(returning: (workouts, deletedIds, newAnchor))
            }
            
            healthStore.execute(query)
        }
        
        let hkWorkouts: [HKWorkout] = response.0
        
        let workouts = await withTaskGroup(of: WorkoutData?.self) { group in

            for hkWorkout in hkWorkouts {
                group.addTask {
                    do {
                        return try await self.fetchWorkoutsMetrics(for: hkWorkout)
                    } catch {
                        return nil
                    }
                }
            }

            var results: [WorkoutData] = []

            for await workout in group {
                if let workout {
                    results.append(workout)
                }
            }

            return results
        }
        
        try? self.saveAnchor(response.2)
        
        return (workouts, response.1)
    }
    
    func fetchWorkoutsMetrics(for hkWorkout: HKWorkout) async throws -> WorkoutData {
        let distance = try await self.fetchDistance(for: hkWorkout)
        let samples = try await self.fetchRunSamples(for: hkWorkout)
        
        let duration = max(
            hkWorkout.endDate.timeIntervalSince(hkWorkout.startDate),
            1
        )
                
        let workout = WorkoutData(
            id: hkWorkout.uuid,
            date: hkWorkout.startDate,
            distance: distance,
            duration: duration,
            elevation: (hkWorkout.metadata?["HKElevationAscended"] as? HKQuantity)?.doubleValue(for: .meter()),
            runSamples: samples.map( {SampleData(time: $0.time, distance: $0.value) })
        )
        
        
        return workout
    }
    
    func fetchWorkoutSeries(
        with id: UUID
    ) async throws -> [MetricSeries] {

        async let heartRate = fetchHeartRateSamples(with: id)
        async let power = fetchPowerSamples(with: id)
        let distance = try await fetchDistanceSamples(with: id)

        let pace = distance
            .sorted(by: { $0.time < $1.time })
            .dropLast()
            .compactMap { sample -> MetricSample? in
                let minute = 2.0 / 60
                let km = sample.value / 1000
                
                var currentPace = minute / km
                
                currentPace = min(currentPace, 12)
                
                return MetricSample(time: sample.time, value: currentPace)
                
            }
        
        return await [
            MetricSeries(
                type: .heartRate,
                samples: try await heartRate,
            ),

            MetricSeries(
                type: .power,
                samples: try await power
            ),

            MetricSeries(
                type: .distance,
                samples: distance
            ),

            MetricSeries(
                type: .pace,
                samples: pace
            )
        ]
    }
    
}
