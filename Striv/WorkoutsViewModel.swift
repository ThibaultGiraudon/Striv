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

class WorkoutsViewModel: ObservableObject {
    @Published var workouts: Workouts = []
    
    func fetchWorkouts() async {
        do {
            let hkWorkouts = try await HealthKitHelper.shared.getWorkouts()
            
            for hkWorkout in hkWorkouts {
                do {
                    let distance = try await HealthKitHelper.shared.fetchDistance(for: hkWorkout)
                    let hr = try await HealthKitHelper.shared.fetchAverageHeartRate(for: hkWorkout)
                    let kcal = try await HealthKitHelper.shared.fetchActiveEnergy(for: hkWorkout)
                    let power = try await HealthKitHelper.shared.fetchPower(for: hkWorkout)
                    let stepCount = try await HealthKitHelper.shared.fetchCadence(for: hkWorkout)
                    let elevation = hkWorkout.metadata?["HKElevationAscended"] as? HKQuantity
                    let routes = try await HealthKitHelper.shared.fetchRoute(for: hkWorkout)
                    
                    var locations: [CLLocation] = []
                    
                    if let firstRoute = routes.first {
                        locations = try await HealthKitHelper.shared.fetchCoordinates(for: firstRoute)
                    }
                    
                    let coordinates = locations.map { $0.coordinate }
                    
                    let duration = hkWorkout.endDate.timeIntervalSince(hkWorkout.startDate)
                    let cadence = (stepCount ?? 0) / (duration / 60)
                    
                    
                    let workout = Workout(date: hkWorkout.startDate, distance: distance, duration: .init(Int(duration)), hr: hr, kcal: kcal, elevation: elevation?.doubleValue(for: .meter()), cadence: cadence, power: power, coordinates: coordinates)
                    self.workouts.append(workout)
                } catch {
                    print(error.localizedDescription)
                    continue
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
