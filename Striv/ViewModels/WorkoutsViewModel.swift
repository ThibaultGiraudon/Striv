//
//  WorkoutsViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation
import Combine
import HealthKit
import CoreLocation
import SwiftData
import _SwiftData_SwiftUI

class WorkoutsViewModel: ObservableObject {
    private var context: ModelContext?
    
    func setContext(context: ModelContext) {
        self.context = context
    }
    
    func fetchWorkoutsSummary() async {
        do {
            guard let context else { return }
            let (hkWorkouts, deletedIDs) = try await HealthKitHelper.shared.syncWorkouts()
            
            let savedWorkouts = getWorkouts()
            
            let workoutsIDs: [UUID] = savedWorkouts.map { $0.id }
            
            for hkWorkout in hkWorkouts {
                do {
                    async let distance = HealthKitHelper.shared.fetchDistance(for: hkWorkout)
                    
                    let duration = hkWorkout.endDate.timeIntervalSince(hkWorkout.startDate)
                    
                    let workout = Workout(
                        id: hkWorkout.uuid,
                        date: hkWorkout.startDate,
                        distance: try await distance,
                        duration: .init(Int(duration)),
                        elevation: (hkWorkout.metadata?["HKElevationAscended"] as? HKQuantity?)??.doubleValue(for: .meter())
                    )

                    if !workoutsIDs.contains(hkWorkout.uuid) {
                        context.insert(workout)
                    }
                } catch {
                    continue
                }
            }
            
            
            for id in deletedIDs {
                guard let workoutToDelete = savedWorkouts.first(where: { $0.id == id }) else {
                    continue
                }
                context.delete(workoutToDelete)
            }
            
            try context.save()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getWorkouts() -> Workouts {
        guard let context = context else { return [] }
        let request = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            return try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    func fetchWorkoutDetail(for workout: Workout) async -> Workout {
        guard let context else { return workout }
        
        let newWorkout = workout
        
        do {
            async let hr = HealthKitHelper.shared.fetchAverageHeartRate(with: workout.id)
            async let kcal = HealthKitHelper.shared.fetchActiveEnergy(with: workout.id)
            async let power = HealthKitHelper.shared.fetchPower(with: workout.id)
            async let stepCount = HealthKitHelper.shared.fetchCadence(with: workout.id)
            async let routes = HealthKitHelper.shared.fetchRoute(with: workout.id)
            
            let resolvedRoutes = try await routes
            
            var locations: [CLLocation] = []
            if let firstRoute = resolvedRoutes.first {
                locations = try await HealthKitHelper.shared.fetchCoordinates(for: firstRoute)
            }
            
            let minutes = max(Double(newWorkout.duration.totalSeconds) / 60, 1)
            let cadence = (try await stepCount ?? 0) / minutes
            
            newWorkout.hr = try await hr
            newWorkout.kcal = try await kcal
            newWorkout.power = try await power
            newWorkout.cadence = cadence
            newWorkout.coordinates = locations
                .sorted { $0.timestamp < $1.timestamp }
                .map { .init(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude, timestamp: $0.timestamp) }
            newWorkout.altitudes = locations.map { $0.altitude }.downSample()
            
            try context.save()
            return newWorkout
        } catch {
            print(error.localizedDescription)
        }
        return workout
    }
    
    func fetchWorkoutDetailIfNeeded(for workout: Workout) async -> Workout {

        if workout.cadence != nil {
            return workout
        }

        return await fetchWorkoutDetail(for: workout)
    }
}
