//
//  HealthKitHelper.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation
import HealthKit
import CoreLocation

/// Helper responsible for interacting with HealthKit.
///
/// `HealthKitHelper` provides a simplified interface to query
/// running workouts and related metrics from HealthKit.
///
/// Responsibilities:
/// - Request HealthKit authorization
/// - Fetch running workouts
/// - Synchronize workouts using anchored queries
/// - Retrieve workout metrics (distance, heart rate, power, etc.)
/// - Retrieve workout routes and coordinates
///
/// This helper is implemented as a shared singleton because
/// HealthKit interactions rely on a single `HKHealthStore` instance.
class HealthKitHelper {
    
    /// The underlying HealthKit store used to execute queries.
    private var healthStore: HKHealthStore?
    
    /// Indicates whether HealthKit is available on the device.
    var isAvailable: Bool { self.healthStore != nil }
    
    /// Indicates whether the application has been authorized
    /// to access HealthKit data.
    var isAuthorized: Bool = false
    
    /// Shared singleton instance used throughout the application.
    static var shared: HealthKitHelper = .init()
    
    /// UserDefaults key used to store the HealthKit anchor.
    private let anchorKey = "healthkit.workout.anchor"
    
    /// Creates a new helper and requests HealthKit authorization.
    private init() {
        self.requestAuthorization()
    }
    
    // MARK: - Authorization
    
    /// Requests authorization to access HealthKit data.
    ///
    /// The application requests read access to:
    /// - Workouts
    /// - Workout routes
    /// - Activity summaries
    /// - Active energy burned
    /// - Heart rate
    /// - Distance walking/running
    /// - Running power
    /// - Step count
    ///
    /// If authorization succeeds, `isAuthorized` becomes `true`.
    func requestAuthorization() -> Bool {
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
            
            return self.isAuthorized
        }
        return false
    }
    
    // MARK: - Workouts
    
    /// Fetches all running workouts from HealthKit.
    ///
    /// Workouts are sorted by most recent start date.
    ///
    /// - Returns: An array of `HKWorkout`.
    /// - Throws: An error if the HealthKit query fails.
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
    
    /// Synchronizes running workouts using an anchored query.
    ///
    /// This method retrieves:
    /// - Newly added workouts
    /// - Workouts deleted from HealthKit
    ///
    /// The last query anchor is stored in `UserDefaults` so
    /// subsequent synchronizations only return incremental changes.
    ///
    /// - Returns: A tuple containing:
    ///   - The new or updated `HKWorkout` objects
    ///   - The identifiers of workouts that were deleted.
    func syncWorkouts() async throws -> ([HKWorkout], [UUID]) {
        guard let healthStore, self.isAuthorized == true else {
            return ([], [])
        }
        
        let anchor = self.getAnchor()
        
        let predicate = HKQuery.predicateForWorkouts(with: .running)
                        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKAnchoredObjectQuery(
                type: .workoutType(),
                predicate: predicate,
                anchor: anchor,
                limit: HKObjectQueryNoLimit) { _, samples, deleted, newAnchor, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    }
                    
                    if let newAnchor {
                        try? self.saveAnchor(newAnchor)
                    }
                    
                    if let samples = samples as? [HKWorkout], let deleted {
                        continuation.resume(returning: (samples, deleted.map { $0.uuid }))
                    }
                }
            healthStore.execute(query)
        }
    }
    
    /// Fetches a specific workout from HealthKit using its identifier.
    ///
    /// - Parameter id: The unique identifier of the workout.
    /// - Returns: The corresponding `HKWorkout`.
    /// - Throws: An error if the workout cannot be found or the query fails.
    func getWorkout(with id: UUID) async throws -> HKWorkout {
        guard let healthStore, self.isAuthorized == true else {
            throw URLError(.unknown) // TODO: create custom error
        }
        
        let predicate = HKQuery.predicateForObject(with: id)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: 1,
                sortDescriptors: nil
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let workout = samples?.first as? HKWorkout else {
                    continuation.resume(throwing: NSError())
                    return
                }

                continuation.resume(returning: workout)
            }

            healthStore.execute(query)
        }
    }
    
    // MARK: - Energy
    
    /// Fetches the average heart rate from the workout with the given id.
    ///
    /// This method:
    /// - Fetches the `HKWorkout` with the corresponding given id.
    /// - Fetches the total active energy.
    ///
    /// - Parameter id: The workout's `UUID` from which energy should be calculated.
    /// - Returns: The total active energy in kilocalories, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
    func fetchActiveEnergy(with id: UUID) async throws -> Double? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchActiveEnergy(for: hkWorkout)
    }
    
    /// Fetches the total active energy burned for a workout.
    ///
    /// - Parameter workout: The workout from which energy should be calculated.
    /// - Returns: The total active energy in kilocalories, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
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
    
    // MARK: - Heart rate
    
    /// Fetches the average heart rate from the workout with the given id.
    ///
    /// This method:
    /// - Fetches the `HKWorkout` with the corresponding given id.
    /// - Fetches the average heart rate.
    ///
    /// - Parameter id: The workout's `UUID` from which heart rate should be calculated.
    /// - Returns: The the average heart rate, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
    func fetchAverageHeartRate(with id: UUID) async throws -> Double? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchAverageHeartRate(for: hkWorkout)
    }
    
    /// Fetches the average heart rate for a workout.
    ///
    /// - Parameter workout: The workout from which heart rate should be calculated.
    /// - Returns: The average heart rate, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
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
    
    // MARK: - Distance
    
    /// Fetches the distance from the workout with the given id.
    ///
    /// This method:
    /// - Fetches the `HKWorkout` with the corresponding given id.
    /// - Fetches the distance.
    ///
    /// - Parameter id: The workout's `UUID` from which distance should be calculated.
    /// - Returns: The the distance, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
    func fetchDistance(with id: UUID) async throws -> Double? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchDistance(for: hkWorkout)
    }
    
    /// Fetches the distance for a workout.
    ///
    /// - Parameter workout: The workout from which distance should be calculated.
    /// - Returns: The distance, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
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
    
    // MARK: - Power
    
    /// Fetches the average power from the workout with the given id.
    ///
    /// This method:
    /// - Fetches the `HKWorkout` with the corresponding given id.
    /// - Fetches the average power.
    ///
    /// - Parameter id: The workout's `UUID` from which power should be calculated.
    /// - Returns: The the average power, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
    func fetchPower(with id: UUID) async throws -> Double? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchPower(for: hkWorkout)
    }
    
    /// Fetches the average power for a workout.
    ///
    /// - Parameter workout: The workout from which power should be calculated.
    /// - Returns: The average power, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
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
    
    // MARK: - Cadence
    
    /// Fetches the average cadence from the workout with the given id.
    ///
    /// This method:
    /// - Fetches the `HKWorkout` with the corresponding given id.
    /// - Fetches the average cadence.
    ///
    /// - Parameter id: The workout's `UUID` from which cadence should be calculated.
    /// - Returns: The the average cadence, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
    func fetchCadence(with id: UUID) async throws -> Double? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchCadence(for: hkWorkout)
    }
    
    /// Fetches the average cadence for a workout.
    ///
    /// - Parameter workout: The workout from which cadence should be calculated.
    /// - Returns: The average cadence, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
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
    
    func fetchRunSamples(with id: UUID) async throws -> [RunSample]? {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchRunSamples(for: hkWorkout)
    }
    
    func fetchRunSamples(for workout: HKWorkout) async throws -> [RunSample] {

        guard let healthStore, self.isAuthorized else {
            return []
        }

        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )

        let startDate = workout.startDate
        let endDate = workout.endDate

        return try await withCheckedThrowingContinuation { continuation in

            let query = HKStatisticsCollectionQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
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
                var runningTotal: Double = 0

                results.enumerateStatistics(from: startDate, to: endDate) { stat, _ in

                    let value = stat.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                    runningTotal += value

                    let time = stat.startDate.timeIntervalSince(startDate)

                    samples.append(
                        RunSample(
                            distance: runningTotal,
                            time: time
                        )
                    )
                }

                continuation.resume(returning: samples)
            }

            healthStore.execute(query)
        }
    }
    
    // MARK: - Route
    
    /// Fetches the run's route from the workout with the given id.
    ///
    /// This method:
    /// - Fetches the `HKWorkout` with the corresponding given id.
    /// - Fetches the runs route.
    ///
    /// - Parameter id: The workout's `UUID` from which route should be calculated.
    /// - Returns: The the runs route, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
    func fetchRoute(with id: UUID) async throws -> [HKWorkoutRoute] {
        let hkWorkout = try await getWorkout(with: id)
        
        return try await fetchRoute(for: hkWorkout)
    }
    
    /// Fetches the runs route for a workout.
    ///
    /// - Parameter workout: The workout from which route should be calculated.
    /// - Returns: The run's route, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
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
    
    // MARK: - Coordinates
    
    /// Fetches the coordinates from a gievn route.
    ///
    /// - Parameter route: The `HKWorkoutRoute` from which coordinates should be retrieved.
    /// - Returns: The average heart rate, or `nil` if unavailable.
    /// - Throws: An error if the HealthKit query fails.
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
    
    // MARK: - Anchor
    
    /// Retrieves the previously stored HealthKit query anchor.
    ///
    /// - Returns: The saved `HKQueryAnchor`, or `nil` if none exists.
    private func getAnchor() -> HKQueryAnchor? {
        guard let anchorData = UserDefaults.standard.value(forKey: self.anchorKey) as? Data,
              let anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: anchorData) else {
            return nil
        }
        
        return anchor
    }
    
    /// Persists a HealthKit query anchor in `UserDefaults`.
    ///
    /// - Parameter anchor: The anchor to save.
    /// - Throws: An error if the anchor cannot be archived.
    private func saveAnchor(_ anchor: HKQueryAnchor) throws {
        let anchorData = try NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
        
        UserDefaults.standard.set(anchorData, forKey: self.anchorKey)
    }
}
