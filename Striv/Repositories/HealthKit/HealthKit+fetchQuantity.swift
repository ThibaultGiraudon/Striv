//
//  HealthKit+fetchQuantity.swift
//  Striv
//
//  Created by Thibault Giraudon on 23/04/2026.
//

import Foundation
import HealthKit

extension HealthKitHelper {
    
    func fetchQuantity(
        for workout: HKWorkout,
        identifier: HKQuantityTypeIdentifier,
        options: HKStatisticsOptions,
        unit: HKUnit
    ) async throws -> Double? {
        
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else {
            throw HealthKitError.invalidType
        }
        
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: options
            ) { _, result, error in
                
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let value: Double?
                
                switch options {
                case .cumulativeSum:
                    value = result?.sumQuantity()?.doubleValue(for: unit)
                case .discreteAverage:
                    value = result?.averageQuantity()?.doubleValue(for: unit)
                default:
                    value = nil
                }
                
                continuation.resume(returning: value)
            }
            
            healthStore.execute(query)
        }
    }
}
