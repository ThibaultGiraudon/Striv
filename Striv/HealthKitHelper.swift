//
//  HealthKitHelper.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation
import HealthKit
import CoreLocation

class HealthKitHelper {
    private var healthStore: HKHealthStore?
    var isAvailable: Bool { self.healthStore != nil }
    var isAuthorized: Bool = false
    
    static var shared: HealthKitHelper = .init()
    
    private init() {
        self.requestAuthorization()
    }
    
    func requestAuthorization() {
        
        if HKHealthStore.isHealthDataAvailable() {
            
            self.healthStore = HKHealthStore()
            
            var typesToRead: Set<HKObjectType> = [.workoutType(), .activitySummaryType(), HKSeriesType.workoutRoute()]
            
            if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                typesToRead.insert(energy)
            }
            
            if let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate) {
                typesToRead.insert(heartRate)
            }
            
            if let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
                typesToRead.insert(distance)
            }
            
            if let power = HKQuantityType.quantityType(forIdentifier: .runningPower) {
                typesToRead.insert(power)
            }
            
            if let cadence = HKQuantityType.quantityType(forIdentifier: .stepCount) {
                typesToRead.insert(cadence)
            }
                         
            healthStore?.requestAuthorization(toShare: [], read: typesToRead) { (success, error) in
                if success {
                    self.isAuthorized = true
                }
                else if let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getWorkouts() async throws -> [HKWorkout] {
        
        guard let healthStore, self.isAuthorized == true else {
            return []
        }
        
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    }
                    
                    if let samples = samples as? [HKWorkout] {
                        continuation.resume(returning: samples)
                    }
            }
            healthStore.execute(query)
        }
        
    }
    
    func fetchActiveEnergy(for workout: HKWorkout) async throws -> Double? {
        
        guard let healthStore, self.isAuthorized == true else {
            return nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            let predicate = HKQuery.predicateForObjects(from: workout)
            
            let query = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let sum = result?.sumQuantity() {
                    continuation.resume(returning: sum.doubleValue(for: .kilocalorie()))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            healthStore.execute(query)
        }
    }
    
    func fetchAverageHeartRate(for workout: HKWorkout) async throws -> Double? {
        
        guard let healthStore, self.isAuthorized == true else {
            return nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            let predicate = HKQuery.predicateForObjects(from: workout)
            
            let query = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let avg = result?.averageQuantity() {
                    continuation.resume(returning: avg.doubleValue(for: HKUnit(from: "count/min")))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            healthStore.execute(query)
        }
    }
    
    func fetchDistance(for workout: HKWorkout) async throws -> Double? {
        
        guard let healthStore, self.isAuthorized == true else {
            return nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            let predicate = HKQuery.predicateForObjects(from: workout)
            
            let query = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let avg = result?.sumQuantity() {
                    continuation.resume(returning: avg.doubleValue(for: HKUnit.meter()))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            healthStore.execute(query)
        }
    }
    
    func fetchPower(for workout: HKWorkout) async throws -> Double? {
        
        guard let healthStore, self.isAuthorized == true else {
            return nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let distanceType = HKQuantityType.quantityType(forIdentifier: .runningPower)!
            let predicate = HKQuery.predicateForObjects(from: workout)
            
            let query = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let avg = result?.averageQuantity() {
                    continuation.resume(returning: avg.doubleValue(for: HKUnit.watt()))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            healthStore.execute(query)
        }
    }
    
    func fetchCadence(for workout: HKWorkout) async throws -> Double? {
        
        guard let healthStore, self.isAuthorized == true else {
            return nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let distanceType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let predicate = HKQuery.predicateForObjects(from: workout)
            
            let query = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let avg = result?.sumQuantity() {
                    continuation.resume(returning: avg.doubleValue(for: HKUnit.count()))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            healthStore.execute(query)
        }
    }
    
    func fetchRoute(for workout: HKWorkout) async throws -> [HKWorkoutRoute] {
        guard let healthStore, self.isAuthorized == true else {
            return []
        }
        
        let routeType = HKSeriesType.workoutRoute()
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        return try await withCheckedThrowingContinuation { continuation in
            let routeQuery = HKAnchoredObjectQuery(type: routeType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObject, anchor, error in
                if let error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: samples as? [HKWorkoutRoute] ?? [])
            }
            healthStore.execute(routeQuery)
        }
    }
    
    func fetchCoordinates(for route: HKWorkoutRoute) async throws -> [CLLocation] {
        guard let healthStore, self.isAuthorized == true else {
            return []
        }
        
        var locations: [CLLocation] = []
        
        return try await withCheckedThrowingContinuation { continuation in
            let routQuery = HKWorkoutRouteQuery(route: route) { _, locs, done, error in
                if let error {
                    continuation.resume(throwing: error)
                }
                
                if let locs {
                    locations.append(contentsOf: locs)
                }
                
                if done {
                    continuation.resume(returning: locations)
                }
            }
            healthStore.execute(routQuery)
        }
    }
    
}
