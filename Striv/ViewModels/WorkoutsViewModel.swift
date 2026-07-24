//
//  WorkoutsViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation
import Combine
import CoreLocation
import SwiftData

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
    
    @Published var isLoading: Bool = false
    
    // MARK: - Depedencies
    
    /// The `ModelContext` used to persist workouts
    private var context: ModelContext?
    
    private var runnerProfileVM: RunnerProfileViewModel?
    
    private var healthKitHelper: HealthKitHelperInterface
    
    init(healthKitHelper: HealthKitHelperInterface, errorPresenter: ErrorPresenter) {
        self.healthKitHelper = healthKitHelper
        super.init(errorPresenter: errorPresenter)
    }
    
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
        
        defer { isLoading = false }
        
        do {
            guard let context else { return }
            isLoading = true
            try await healthKitHelper.requestAuthorization()
            let (workouts, deletedIDs) = try await healthKitHelper.syncWorkouts()
            
            let savedWorkouts = getWorkouts()
            
            var newWorkouts: [WorkoutData] = []
            
            let workoutsIDs: [UUID] = savedWorkouts.map { $0.id }
                        
            for workoutData in workouts {
                if !workoutsIDs.contains(workoutData.id) {
                    context.insert(Workout(id: workoutData.id, date: workoutData.date, distance: workoutData.distance, duration: .init(Int(workoutData.duration)), elevation: workoutData.elevation))
                    newWorkouts.append(workoutData)
                }
            }
            
            self.processNewWorkout(newWorkouts)
            
            for id in deletedIDs {
                guard let workoutToDelete = savedWorkouts.first(where: { $0.id == id }) else {
                    continue
                }
                context.delete(workoutToDelete)
            }
            
            try context.save()
        } catch _ as HealthKitError {
            self.errorPresenter.error = .healthKit(.noDataOrNoPermission)
        } catch {
            self.errorPresenter.error = .database(.saving)
        }
    }
    
    func processNewWorkout(_ workouts: [WorkoutData]) {
        Task.detached(priority: .background) {
            do {
                let prs = try await PRCalculator().process(workouts)
                
                await MainActor.run {
                    _ = self.runnerProfileVM?.updatePRs(prs)
                }
                
            } catch {
                await MainActor.run {
                    self.errorPresenter.error = .database(.saving)
                }
            }
        }
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

struct SampleData: Sendable {
    let time: TimeInterval
    let distance: Double
}

struct WorkoutData: Sendable {
    let id: UUID
    let date: Date
    let distance: Double?
    let duration: Double
    let elevation: Double?
    let runSamples: [SampleData]
}

final class PRCalculator {

    func process(_ workouts: [WorkoutData]) async throws -> [PRResult] {
        
        let unprocessed = workouts.filter {
            ($0.distance ?? 0) > PresetDistance.fiveK.meters
        }
        var allPRs: [PRResult] = []

        
        for workout in unprocessed {
            let prs = await processWorkout(workout)

            allPRs.append(contentsOf: prs)
            await Task.yield()
        }
        
        return allPRs
    }

    private func processWorkout(_ workout: WorkoutData) async -> [PRResult] {
        let samples = workout.runSamples

        let result = await bestTimes(in: samples)
        
        let prs = result.map {
            PRResult(
                time: $0.value,
                workoutId: workout.id,
                date: workout.date,
                prDistance: $0.key
            )
        }

        return prs
    }

    private func bestTimes(in samples: [SampleData]) async -> [PresetDistance: TimeInterval] {

        guard samples.count > 100 else {
            return [:]
        }

        var times: [PresetDistance: TimeInterval] = [:]
        var start = 0

        for end in samples.indices {
            
            while start < end &&
                  samples[end].distance - samples[start].distance > PresetDistance.marathon.meters {
                start += 1
            }

            let currentDistance =
                samples[end].distance - samples[start].distance

            for target in PresetDistance.allCases {

                guard currentDistance >= target.meters - 5 else {
                    continue
                }

                let time =
                    samples[end].time - samples[start].time

                guard time > 10 else {
                    continue
                }

                if let current = times[target] {
                    times[target] = min(current, time)
                } else {
                    times[target] = time
                }
            }
        }

        return times
    }
}
