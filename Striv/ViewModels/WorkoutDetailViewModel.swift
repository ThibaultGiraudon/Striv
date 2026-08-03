//
//  WorkoutDetailViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 22/07/2026.
//

import Foundation
import Combine
import SwiftData
import CoreLocation

@Model
final class WorkoutSplit: Identifiable, Hashable {
    var id = UUID()
    var km: Double
    var pace: Pace
    var elevation: Int
    var hr: Int
    var index: Int
    
    init(id: UUID = UUID(), km: Double, pace: Pace, elevation: Int, hr: Int, index: Int) {
        self.id = id
        self.km = km
        self.pace = pace
        self.elevation = elevation
        self.hr = hr
        self.index = index
    }
}

// TODO: - Save splits in workouts

class WorkoutDetailViewModel: BaseViewModel {
    @Published var workout: Workout
    
    @Published var sortedSplits: [WorkoutSplit] = []

    @Published var paceSeries: MetricSeriesEntity?
    @Published var heartRateSeries: MetricSeriesEntity?
    @Published var elevationSeries: MetricSeriesEntity?
    @Published var powerSeries: MetricSeriesEntity?

    @Published var bestSplit: Pace?

    @Published var fastestPace: Pace?

    @Published var maxHeartRate: Double?

    @Published var minElevation: Double?
    @Published var maxElevation: Double?
    
    @Published var isLoading: Bool = false
    
    private var context: ModelContext?
    
    private var healthKitHelper: HealthKitHelperInterface
    
    init(workout: Workout, healthKitHelper: HealthKitHelperInterface, errorPresenter: ErrorPresenter) {
        self.workout = workout
        self.healthKitHelper = healthKitHelper
        super.init(errorPresenter: errorPresenter)
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
    func fetchWorkoutDetail(for workout: Workout) async {
        guard let context else { return }
        
        defer { isLoading = false}
        let newWorkout = workout
        
        do {
            isLoading = true
            async let hr = healthKitHelper.fetchAverageHeartRate(with: workout.id)
            async let kcal = healthKitHelper.fetchActiveEnergy(with: workout.id)
            async let power = healthKitHelper.fetchPower(with: workout.id)
            async let stepCount = healthKitHelper.fetchCadence(with: workout.id)
            let metricsSeries = try await healthKitHelper.fetchWorkoutSeries(with: workout.id)
            
            let minutes = max(Double(newWorkout.duration.totalSeconds) / 60, 1)
            let cadence = (try await stepCount ?? 0) / minutes
            
            newWorkout.hr = try await hr
            newWorkout.kcal = try await kcal
            newWorkout.power = try await power
            newWorkout.cadence = cadence
            
            var normalizedSeries: [MetricSeriesEntity] = []
            
            for serie in metricsSeries {
                normalizedSeries.append(MetricSeriesEntity(type: serie.type, samples: normalizeSamples(serie.type, for: serie.samples)))
            }

            newWorkout.metricsSeries = normalizedSeries
            
            await self.fetchWorkoutRoutes(for: workout)
            
            try context.save()
        } catch let err as HealthKitError {
            if err == .noData {
                
            } else {
                self.errorPresenter.error = .unknown()
            }
        } catch {
            self.errorPresenter.error = .database(.saving)
        }
    }
    
    func normalizeSamples(_ type: MetricType, for samples: [MetricSample]) -> [MetricSample] {
        let minValue = samples.map(\.value).min() ?? 0
        let maxValue = samples.map(\.value).max() ?? 0
        
        guard maxValue != minValue else {
            return samples.map {
                .init(
                    time: $0.time,
                    value: $0.value,
                    normalizedValue: 0.5
                )
            }
        }
        
        return samples.map {
            var normalizedValue = (($0.value - minValue) / (maxValue - minValue))
            
            if type == .pace {
                normalizedValue = 1 - normalizedValue
            }
            
            return .init(
                time: $0.time,
                value: $0.value,
                normalizedValue: normalizedValue
            )
        }
    }
    
    func fetchWorkoutRoutes(for workout: Workout) async {
        guard let context else { return }
        
        guard workout.coordinates.isEmpty else { return }
        
        do {
            let locations = try await healthKitHelper.fetchCoordinates(with: workout.id)
            workout.coordinates = locations
                .sorted { $0.timestamp < $1.timestamp }
                .map { .init(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude, timestamp: $0.timestamp) }
            workout.altitudes = locations.map { $0.altitude }.downSample()
            let startDate = locations.sorted { $0.timestamp < $1.timestamp }.first?.timestamp ?? .now
            let elevationSamples: [MetricSample] = locations.map { .init(time: $0.timestamp.timeIntervalSince(startDate), value: $0.altitude)}
            workout.metricsSeries.append(.init(type: .elevation, samples: normalizeSamples(.elevation, for: elevationSamples)))
                        
            try context.save()
            
        } catch {
            self.errorPresenter.error = .database(.saving)
        }
    }
        
    /// Fetches workout details only if they are not already available.
    ///
    /// - Parameter workout: The workout to check.
    /// - Returns: The original workout if details are already present,
    ///   otherwise the workout updated with detailed metrics.
    func fetchWorkoutDetailIfNeeded(for workout: Workout) async {
        guard workout.cadence == nil else {
            return
        }

        await fetchWorkoutDetail(for: workout)
    }
    
    // MARK: - Configuration
    
    /// Sets the `ModelContext` used to persist workouts in SwiftData.
    ///
    /// - Parameter context: A shared `ModelContext` used across the app
    ///   to fetch and save workout data.
    func setContext(context: ModelContext) {
        self.context = context
    }
    
    func prepareData() async {

        // MARK: Splits
        await self.fetchWorkoutDetailIfNeeded(for: workout)
        
        self.getSplitsIfNeeded()

        sortedSplits = workout.splits.sorted {
            $0.index < $1.index
        }

        bestSplit = workout.splits
            .map(\.pace)
            .min()

        // MARK: Series

        paceSeries = workout.metricsSeries.first {
            $0.type == .pace
        }

        heartRateSeries = workout.metricsSeries.first {
            $0.type == .heartRate
        }

        elevationSeries = workout.metricsSeries.first {
            $0.type == .elevation
        }

        powerSeries = workout.metricsSeries.first {
            $0.type == .power
        }

        // MARK: Pace

        if let paceSeries {

            fastestPace = paceSeries.samples
                .map(\.value)
                .min()
                .map(Pace.init)
        }

        // MARK: Heart Rate

        if let heartRateSeries {

            maxHeartRate = heartRateSeries.samples
                .map(\.value)
                .max()
        }

        // MARK: Elevation

        if let elevationSeries {

            minElevation = elevationSeries.samples
                .map(\.value)
                .min()

            maxElevation = elevationSeries.samples
                .map(\.value)
                .max()
        }
    }
    
    func getSplits() -> [WorkoutSplit] {
        
        guard let distanceSamples = workout.metricsSeries.first(where: { $0.type == .distance })?.samples.sorted(by: { $0.time < $1.time }),
              let paceSamples = workout.metricsSeries.first(where: { $0.type == .pace })?.samples.sorted(by: { $0.time < $1.time }),
              let hrSamples = workout.metricsSeries.first(where: { $0.type == .heartRate })?.samples.sorted(by: { $0.time < $1.time }),
              let elevations = workout.metricsSeries.first(where: { $0.type == .elevation })?.samples.sorted(by: { $0.time < $1.time })
        else {
            return []
        }
        
        let elevationSamples = self.getElevation(from: elevations)
        var splits: [WorkoutSplit] = []

        var accumulatedDistance = 0.0
        var currentKm = 1

        var splitStartTime = distanceSamples.first?.time ?? 0


        for distanceSample in distanceSamples {

            accumulatedDistance += distanceSample.value

            guard accumulatedDistance >= 1000 else {
                continue
            }

            let splitEndTime = distanceSample.time


            let splitPaceSamples = paceSamples.filter {
                $0.time >= splitStartTime &&
                $0.time <= splitEndTime
            }

            let splitHRSamples = hrSamples.filter {
                $0.time >= splitStartTime &&
                $0.time <= splitEndTime
            }
            
            let splitElevationSamples = elevationSamples.filter {
                $0.time >= splitStartTime &&
                $0.time <= splitEndTime
            }


            let averagePace = splitPaceSamples.isEmpty
                ? 0
                : splitPaceSamples.map(\.value).reduce(0, +)
                / Double(splitPaceSamples.count)


            let averageHR = splitHRSamples.isEmpty
                ? 0
                : splitHRSamples.map(\.value).reduce(0, +)
                / Double(splitHRSamples.count)

            let split = WorkoutSplit(
                km: Double(currentKm),
                pace: .init(pace: averagePace),
                elevation: Int(splitElevationSamples.map(\.value).reduce(0, +)),
                hr: Int(averageHR),
                index: currentKm
            )

            splits.append(split)

            currentKm += 1

            accumulatedDistance -= 1000
            splitStartTime = splitEndTime
        }


        if accumulatedDistance > 100 {

            let splitPaceSamples = paceSamples.filter {
                $0.time >= splitStartTime
            }

            let splitHRSamples = hrSamples.filter {
                $0.time >= splitStartTime
            }

            let splitElevationSamples = elevationSamples.filter {
                $0.time >= splitStartTime
            }

            let averagePace = splitPaceSamples.isEmpty
                ? 0
                : splitPaceSamples.map(\.value).reduce(0, +)
                / Double(splitPaceSamples.count)


            let averageHR = splitHRSamples.isEmpty
                ? 0
                : splitHRSamples.map(\.value).reduce(0, +)
                / Double(splitHRSamples.count)

            splits.append(
                WorkoutSplit(
                    km: accumulatedDistance / 1000,
                    pace: .init(pace: averagePace),
                    elevation: Int(splitElevationSamples.map(\.value).reduce(0, +)),
                    hr: Int(averageHR),
                    index: currentKm
                )
            )
        }

        return splits
    }
    
    func getSplitsIfNeeded() {
        guard workout.splits.isEmpty else { return }
        
        let splits = self.getSplits()
        
        workout.splits = splits
        do {
            try context?.save()
        } catch {
            self.errorPresenter.error = .database(.saving)
        }
    }
    
    func getElevation(from samples: [MetricSampleEntity]) -> [MetricSampleEntity] {
        var elevationSamples: [MetricSampleEntity] = []
        
        for index in samples.indices {
            guard index < samples.count - 1 else {
                continue
            }
            
            let delta = samples[index + 1].value - samples[index].value
            
            elevationSamples.append(.init(time: samples[index].time, value: delta))
        }
        
        return elevationSamples
    }
}
