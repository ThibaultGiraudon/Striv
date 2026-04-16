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



struct PRprocessingState: Codable {
    var processedWorkoutIDs: Set<UUID>
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

/// ViewModel responsible for managing workout data.
///
/// `WorkoutsViewModel` synchronizes running workouts from HealthKit
/// and persists them locally using SwiftData.
/// It uses `HealthKitHelper` to fetch workout summaries and detailed metrics.
class WorkoutsViewModel: ObservableObject {
    
    private var stateKey: String = "striv.state.key"
    
    // MARK: - Depedencies
    
    /// The `ModelContext` used to persist workouts
    private var context: ModelContext?
    
    private var runnerProfileVM: RunnerProfileViewModel?
    
    // MARK: - Configuration
    
    /// Sets the `ModelContext` used to persist workouts in SwiftData.
    ///
    /// - Parameter context: A shared `ModelContext` used across the app
    ///   to fetch and save workout data.
    func setContext(context: ModelContext) {
        self.context = context
    }
    
    func setRunnerProfileVM(_ profileVM: RunnerProfileViewModel) {
        self.runnerProfileVM = profileVM
    }
    
    // MARK: - Fetching
    
    /// Synchronizes workout summaries with HealthKit.
    ///
    /// This method:
    /// - Fetches new or updated workouts from HealthKit.
    /// - Creates new `Workout` objects with essential summary data.
    /// - Inserts workouts that are not yet stored locally.
    /// - Removes workouts that were deleted from the Apple Health app.
    func fetchWorkoutsSummary() async {
        do {
            guard let context else { return }
            let (hkWorkouts, deletedIDs) = try await HealthKitHelper.shared.syncWorkouts()
            
            let savedWorkouts = getWorkouts()
            
            var newWorkouts: [Workout] = []
            
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
                        newWorkouts.append(workout)
                    }
                } catch {
                    continue
                }
            }
            
            await self.processNewWorkout(newWorkouts)
            
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
    
    func fetchWorkoutRoutes(for workout: Workout) async{
        guard let context else { return }
        
        guard workout.coordinates.isEmpty else { return }
        
        do {
            async let routes = HealthKitHelper.shared.fetchRoute(with: workout.id)
            
            let resolvedRoutes = try await routes
            
            var locations: [CLLocation] = []
            if let firstRoute = resolvedRoutes.first {
                locations = try await HealthKitHelper.shared.fetchCoordinates(for: firstRoute)
            }
            
            workout.coordinates = locations
                .sorted { $0.timestamp < $1.timestamp }
                .map { .init(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude, timestamp: $0.timestamp) }
            workout.altitudes = locations.map { $0.altitude }.downSample()
            
            try context.save()
            
        } catch {
            print(error)
        }
    }
    
    func processNewWorkout(_ workouts: [Workout]) async {
        await Task.detached(priority: .background) {
            await self.process(workouts)
        }.value
    }
    
    private func process(_ workouts: [Workout]) async {
        var state = self.getState()
        
        let unprocessed = workouts.filter {
            !state.processedWorkoutIDs.contains($0.id)
        }
        
        let batchSize = 5
        
        for batch in unprocessed.chunked(into: batchSize) {
            
            await processBatch(batch, state: &state)
            
            do {
                try self.saveState(state)
            } catch {
                print("Failed to save state: \(error.localizedDescription)")
            }
            // laisse iOS respirer
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
    }
    
    func processBatch(_ batch: [Workout], state: inout PRprocessingState) async {

        for workout in batch {

            await fetchWorkoutRoutes(for: workout)

            let prs = computePRs(for: workout)

            _ = runnerProfileVM?.updatePRs(prs)
            
            state.processedWorkoutIDs.insert(workout.id)
        }
    }
    
    // MARK: - Anchor
    
    /// Retrieves the previously stored HealthKit query anchor.
    ///
    /// - Returns: The saved `HKQueryAnchor`, or `nil` if none exists.
    private func getState() -> PRprocessingState {
        guard let stateData = UserDefaults.standard.value(forKey: self.stateKey) as? Data,
              let state = try? JSONDecoder().decode(PRprocessingState.self, from: stateData) else {
            return PRprocessingState(processedWorkoutIDs: [])
        }
        
        return state
    }
    
    /// Persists a HealthKit query anchor in `UserDefaults`.
    ///
    /// - Parameter anchor: The anchor to save.
    /// - Throws: An error if the anchor cannot be archived.
    private func saveState(_ state: PRprocessingState) throws {
        let stateData = try JSONEncoder().encode(state)
        
        UserDefaults.standard.set(stateData, forKey: self.stateKey)
    }
    
    
    
    /// Fetches detailed metrics for a given workout.
    ///
    /// This method retrieves additional data from HealthKit including:
    /// - Heart rate
    /// - Active energy
    /// - Running power
    /// - Cadence
    /// - Route coordinates
    /// - Altitude samples
    ///
    /// The workout is then updated and persisted in SwiftData.
    ///
    /// - Parameter workout: The workout for which details should be fetched.
    /// - Returns: The updated workout containing the fetched metrics.
    func fetchWorkoutDetail(for workout: Workout) async -> Workout {
        guard let context else { return workout }
        
        let newWorkout = workout
        
        do {
            async let hr = HealthKitHelper.shared.fetchAverageHeartRate(with: workout.id)
            async let kcal = HealthKitHelper.shared.fetchActiveEnergy(with: workout.id)
            async let power = HealthKitHelper.shared.fetchPower(with: workout.id)
            async let stepCount = HealthKitHelper.shared.fetchCadence(with: workout.id)
            
            let minutes = max(Double(newWorkout.duration.totalSeconds) / 60, 1)
            let cadence = (try await stepCount ?? 0) / minutes
            
            newWorkout.hr = try await hr
            newWorkout.kcal = try await kcal
            newWorkout.power = try await power
            newWorkout.cadence = cadence
            
            try context.save()
            return newWorkout
        } catch {
            print(error.localizedDescription)
        }
        return workout
    }
    
    /// Fetches workout details only if they are not already available.
    ///
    /// - Parameter workout: The workout to check.
    /// - Returns: The original workout if details are already present,
    ///   otherwise the workout updated with detailed metrics.
    func fetchWorkoutDetailIfNeeded(for workout: Workout) async -> Workout {

        if workout.cadence != nil {
            return workout
        }

        return await fetchWorkoutDetail(for: workout)
    }
    
    func bestTime(for targetDistance: Double, in samples: [RunSample]) -> TimeInterval? {
        var best: TimeInterval?
        var start = 0

        for end in 0..<samples.count {
            while samples[end].distance - samples[start].distance > targetDistance {
                start += 1
            }

            let currentDistance = samples[end].distance - samples[start].distance

            if currentDistance >= targetDistance - 5 {
                let time = samples[end].time - samples[start].time
                if time > 10 {
                    best = min(best ?? time, time)
                }
            }
        }

        return best
    }
    
    func computePRs(for workout: Workout) -> [PRResult] {

        var results: [PRResult] = []

        for target in PresetDistance.allCases {
            var bestResult: PRResult?
            let samples = workout.samples
            guard samples.count > 100 else { continue }
            guard (workout.distance ?? 0) > target.meters else { continue }

            if let time = bestTime(for: target.meters, in: samples) {
                let candidate = PRResult(
                    distance: target.meters,
                    time: time,
                    workoutId: workout.id,
                    date: workout.date,
                    prDistance: target
                )

                if bestResult == nil || time < bestResult!.time {
                    bestResult = candidate
                }
            }

            if let bestResult {
                results.append(bestResult)
            }
        }
        
        return results
    }
    
    // MARK: - Private
    
    /// Fetches workouts stored in SwiftData.
    ///
    /// - Returns: An array of `Workout` objects sorted by most recent date.
    private func getWorkouts() -> Workouts {
        guard let context = context else { return [] }
        let request = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            return try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
}
