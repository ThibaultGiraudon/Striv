//
//  WorkoutDetailViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 22/07/2026.
//

import Foundation
import Combine

struct WorkoutSplit: Identifiable, Hashable {
    var id = UUID()
    var km: Double
    var pace: Workout.Pace
    var elevation: Int
    var hr: Int
    var index: Int
}

class WorkoutDetailViewModel: ObservableObject {
    @Published var workout: Workout
    
    init(workout: Workout) {
        self.workout = workout
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


            print(split)


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
