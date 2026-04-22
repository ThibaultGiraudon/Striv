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
class WorkoutsViewModel: BaseViewModel {
    
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
                    async let samples = HealthKitHelper.shared.fetchRunSamples(for: hkWorkout)
                    
                    let duration = hkWorkout.endDate.timeIntervalSince(hkWorkout.startDate)
                    
                    let workout = Workout(
                        id: hkWorkout.uuid,
                        date: hkWorkout.startDate,
                        distance: try await distance,
                        duration: .init(Int(duration)),
                        elevation: (hkWorkout.metadata?["HKElevationAscended"] as? HKQuantity?)??.doubleValue(for: .meter()),
                    )
                    
                    try await workout.samples = samples.sorted(by: {$0.time < $1.time})
                    
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
            self.errorPresenter.error = .database(.saving)
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
            self.errorPresenter.error = .database(.saving)
        }
    }
    
    func processNewWorkout(_ workouts: [Workout]) async {
        Task(priority: .background) {
            await self.process(workouts)
        }
    }
    
    private func process(_ workouts: [Workout]) async {
        var state = self.getState()
        
        let unprocessed = workouts.filter {
            !state.processedWorkoutIDs.contains($0.id) && ($0.distance ?? 0) > PresetDistance.fiveK.meters
        }
        
        let batchSize = ProcessInfo.processInfo.activeProcessorCount
        
        for batch in unprocessed.chunked(into: batchSize) {
            
            await processBatch(batch, state: &state)
            
            do {
                try self.saveState(state)
            } catch {
                self.errorPresenter.error = .database(.saving)
            }

            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
    
    func processBatch(_ batch: [Workout], state: inout PRprocessingState) async {

        for workout in batch {
            
            let sortedSample = workout.samples.sorted(by: { $0.time < $1.time })
            
            let bestTimes = self.bestTimes(in: sortedSample)
            
            let prs = bestTimes.map {
                PRResult(
                    time: $0.value,
                    workoutId: workout.id,
                    date: workout.date,
                    prDistance: $0.key
                )
            }

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
            
            await self.fetchWorkoutRoutes(for: workout)
            
            try context.save()
            return newWorkout
        } catch {
            self.errorPresenter.error = .database(.saving)
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
    
    func bestTimes(in samples: [RunSample]) -> [PresetDistance: TimeInterval] {

        var times: [PresetDistance: TimeInterval] = [:]

        guard samples.count > 100 else { return [:] }

        var start = 0

        for end in 0..<samples.count {

            while start < end &&
                  samples[end].distance - samples[start].distance > PresetDistance.marathon.meters {
                start += 1
            }

            let currentDistance = samples[end].distance - samples[start].distance

            for target in PresetDistance.allCases {

                guard currentDistance >= target.meters - 5 else {
                    continue
                }
                
                let time = samples[end].time - samples[start].time
                guard time > 10 else { continue }

                if let current = times[target] {
                    times[target] = min(current, time)
                } else {
                    times[target] = time
                }
            }
        }

        return times
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
            self.errorPresenter.error = .database(.fetching)
        }
        
        return []
    }
}
