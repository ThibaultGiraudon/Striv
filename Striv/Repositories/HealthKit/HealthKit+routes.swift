//
//  HealthKit+routes.swift
//  Striv
//
//  Created by Thibault Giraudon on 23/04/2026.
//

import Foundation
import HealthKit
import CoreLocation

extension HealthKitHelper {
    
    func fetchRoute(with id: UUID) async throws -> [HKWorkoutRoute] {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchRoute(for: hkWorkout)
    }
    
    func fetchRoute(for workout: HKWorkout) async throws -> [HKWorkoutRoute] {
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKAnchoredObjectQuery(
                type: HKSeriesType.workoutRoute(),
                predicate: predicate,
                anchor: nil,
                limit: HKObjectQueryNoLimit
            ) { _, samples, _, _, error in
                
                if let error {
                    if let hkError = error as? HKError,
                       hkError.code == .errorNoData {
                        continuation.resume(returning: [])
                        return
                    }
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: samples as? [HKWorkoutRoute] ?? [])
            }
            
            healthStore.execute(query)
        }
    }
    
    func fetchCoordinates(with id: UUID) async throws -> [CLLocation] {
        let routes = try await self.fetchRoute(with: id)
        guard let firstRoute = routes.first else { return [] }
        var locations: [CLLocation] = []
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKWorkoutRouteQuery(route: firstRoute) { _, locs, done, error in
                
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let locs {
                    locations.append(contentsOf: locs)
                }
                
                if done {
                    continuation.resume(returning: locations)
                }
            }
            
            healthStore.execute(query)
        }
    }
}
