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
            healthStore = HKHealthStore()
            let workoutType = HKSampleType.workoutType()
            self.healthStore?.requestAuthorization(toShare: nil, read: [workoutType]) { (success, error) in
                if success {
                    self.isAuthorized = true
                }
            }
        }
    }
    
    func getWorkouts(completion: @escaping (Result<[HKWorkout], Error>) -> Void) {
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: predicate,
            limit: 0,
            sortDescriptors: [sortDescriptor]) { query, samples, error in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let samples = samples as? [HKWorkout] {
                    completion(.success(samples))
                }
        }
        
        self.healthStore?.execute(query)
    }
}
