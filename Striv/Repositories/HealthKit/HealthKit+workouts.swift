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
        
        let response: ([HKWorkout], [UUID]) = try await withCheckedThrowingContinuation { continuation in
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
                
                if let newAnchor {
                    try? self.saveAnchor(newAnchor)
                }
                
                let workouts = samples as? [HKWorkout] ?? []
                let deletedIds = deleted?.map(\.uuid) ?? []
                
                continuation.resume(returning: (workouts, deletedIds))
            }
            
            healthStore.execute(query)
        }
        
        let hkWorkouts: [HKWorkout] = response.0

        let workouts = try await withThrowingTaskGroup(of: WorkoutData.self) { group in

            for hkWorkout in hkWorkouts {
                group.addTask {
                    try await self.fetchWorkoutsMetrics(for: hkWorkout)
                }
            }

            var results: [WorkoutData] = []

            for try await workout in group {
                results.append(workout)
            }

            return results
        }
        
        
        return (workouts, response.1)
    }
    
    func fetchWorkoutsMetrics(for hkWorkout: HKWorkout) async throws -> WorkoutData {
        async let distance = self.fetchDistance(for: hkWorkout)
        let samples = try await self.fetchRunSamples(for: hkWorkout)
        
        let duration = hkWorkout.endDate.timeIntervalSince(hkWorkout.startDate)
        
        let workout = WorkoutData(
            id: hkWorkout.uuid,
            date: hkWorkout.startDate,
            distance: try await distance,
            duration: duration,
            elevation: (hkWorkout.metadata?["HKElevationAscended"] as? HKQuantity)?.doubleValue(for: .meter()),
            samples: samples.map {
                .init(time: $0.time, distance: $0.distance)
            }
        )
        
        
        return workout
    }
}
