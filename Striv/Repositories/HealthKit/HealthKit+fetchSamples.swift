//
//  HealthKit+fetchSamples.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/06/2026.
//

import Foundation
import HealthKit

extension HealthKitHelper {
    func fetchSamples(
        for workout: HKWorkout,
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        options: HKStatisticsOptions
    ) async throws -> [RunSample] {

        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else {
            throw HealthKitError.invalidType
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )

        let startDate = workout.startDate
        let endDate = workout.endDate

        return try await withCheckedThrowingContinuation { continuation in

            guard startDate < endDate else {
                continuation.resume(returning: [])
                return
            }

            let query = HKStatisticsCollectionQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: options,
                anchorDate: startDate,
                intervalComponents: DateComponents(second: 2)
            )

            query.initialResultsHandler = { _, results, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results else {
                    continuation.resume(returning: [])
                    return
                }

                var samples: [RunSample] = []

                results.enumerateStatistics(from: startDate, to: endDate) { stat, _ in

                    let quantity: HKQuantity?

                    switch options {
                    case .cumulativeSum:
                        quantity = stat.sumQuantity()

                    case .discreteAverage:
                        quantity = stat.averageQuantity()

                    default:
                        quantity = stat.averageQuantity() ?? stat.sumQuantity()
                    }

                    guard let quantity else { return }

                    let value = quantity.doubleValue(for: unit)

                    let time = stat.startDate.timeIntervalSince(startDate)

                    samples.append(
                        RunSample(
                            distance: value,
                            time: time
                        )
                    )
                }

                continuation.resume(returning: samples)
            }

            healthStore.execute(query)
        }
    }
}
