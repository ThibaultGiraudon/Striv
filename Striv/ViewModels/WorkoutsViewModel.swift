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
import FirebaseAILogic

@MainActor
class WorkoutsViewModel: ObservableObject {
    @Published var workouts: Workouts = [] 
    @Published var error: AIError?
    @Published private(set) var weeklyStats: [WeeklyStat] = []
    
    private let aiRepository: AIRepository = .init()
    
    private var isConnected: Bool = false
    private let networkMonitor = NetworkMonitor()
    
    func fetchWorkoutsSummary() async {
        do {
            let hkWorkouts = try await HealthKitHelper.shared.getWorkouts()
            
            var newWorkouts: [Workout] = []
            
            try await withThrowingTaskGroup(of: Workout?.self) { group in
                
                for hkWorkout in hkWorkouts {
                    group.addTask {
                        do {
                            async let distance = HealthKitHelper.shared.fetchDistance(for: hkWorkout)
                            
                            let duration = hkWorkout.endDate.timeIntervalSince(hkWorkout.startDate)
                            
                            return await Workout(
                                id: hkWorkout.uuid,
                                date: hkWorkout.startDate,
                                distance: try await distance,
                                duration: .init(Int(duration)),
                                elevation: (hkWorkout.metadata?["HKElevationAscended"] as? HKQuantity?)??.doubleValue(for: .meter())
                            )
                            
                        } catch {
                            return nil
                        }
                    }
                }
                
                for try await workout in group {
                    if let workout {
                        newWorkouts.append(workout)
                    }
                }
            }
            
            await MainActor.run {
                self.workouts = newWorkouts.sorted(by: {$0.date > $1.date})
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchWorkoutDetail(for workout: Workout) async -> Workout {
        guard let index = self.workouts.firstIndex(where: {$0.id == workout.id}) else {
            return workout
        }
        
        var newWorkout = workout
        
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
            newWorkout.coordinates = locations.map { $0.coordinate }
            newWorkout.altitudes = locations.map { $0.altitude }.downSample()
            
            self.workouts[index] = newWorkout
            return newWorkout
        } catch {
            print(error.localizedDescription)
        }
        return workout
    }
    
    func fetchWorkoutDetailIfNeeded(for workout: Workout) async -> Workout {
        guard let index = self.workouts.firstIndex(where: { $0.id == workout.id }) else {
            return workout
        }

        if workouts[index].cadence != nil {
            return workouts[index]
        }

        return await fetchWorkoutDetail(for: workout)
    }
    
    
    func getWorkoutAnalyse(for workout: Workout) async -> Analyse? {
        self.error = nil
        do {
            if networkMonitor.execute() {
                return try await self.aiRepository.askGemini(with: workout.analysePrompt)
            } else {
                self.error = .connection
            }
        } catch {
            if error as? GenerateContentError != nil {
                self.error = .internalAI
            } else {
                self.error = .invalid
            }
        }
        return nil
    }
}

extension WorkoutsViewModel {
    enum AIError: Error, LocalizedError, Hashable {
        case internalAI
        case invalid
        case connection
        
        var title: String {
            switch self {
            case .internalAI:
                "Service error."
            case .invalid:
                "Internal error."
            case .connection:
                "No internet connection."
            }
        }
        
        var description: String {
            switch self {
            case .internalAI:
                "The service is currently unable to process your request."
            case .invalid:
                "We failed to process your request"
            case .connection:
                "Please check your connection and try again."
            }
        }
        
        var icon: String {
            switch self {
            case .internalAI:
                "wrench.and.screwdriver"
            case .invalid:
                "externaldrive.trianglebadge.exclamationmark"
            case .connection:
                "wifi.slash"
            }
        }
    }
}
