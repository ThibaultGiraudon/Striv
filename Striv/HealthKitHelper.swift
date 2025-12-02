//
//  HealthKitHelper.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation
import HealthKit

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
            
            var typesToRead: Set<HKObjectType> = [.workoutType(), .activitySummaryType()]
            
            if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                typesToRead.insert(energy)
            }
            
            if let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate) {
                typesToRead.insert(heartRate)
            }
            
            if let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
                typesToRead.insert(distance)
            }
            
            healthStore?.requestAuthorization(toShare: [], read: typesToRead) { (success, error) in
                if success {
                    self.isAuthorized = true
                }
                else {
                    print(error?.localizedDescription)
                }
            }
        }
    }
    
    func getWorkouts() async throws -> [HKWorkout] {
        
        guard let healthStore, self.isAuthorized == true else {
            return []
        }
        
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: 0,
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
}
