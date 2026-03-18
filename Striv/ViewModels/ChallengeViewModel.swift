//
//  ChallengeViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 18/03/2026.
//

import Foundation
import Combine

class ChallengeViewModel: ObservableObject {
    @Published var challenges: [Challenge] = [
        Challenge(title: "1000km", description: "Cummuler 1000km de course", challengeType: .distance(total: 10)),
        Challenge(title: "+400m", description: "Réaliser une course avec un dénivelé cummulé de +400m", challengeType: .elevation(total: 400)),
        Challenge(title: "150 courses", description: "Enregistrer 150 courses", challengeType: .runs(number: 150)),
        Challenge(title: "10km", description: "Réaliser une course de 10km", challengeType: .singleRun(distance: 10)),
        Challenge(title: "1 mois", description: "Réaliser une course par jour pendant 30 jours", challengeType: .streak(number: 30))
    ]
    
    func updateAllChallenges(with workouts: [Workout]) {
        challenges = challenges.map { challenge in
            var updated = challenge
            
            let (progress, date) = computeProgress(for: challenge, workouts: workouts)
            
            updated.progression = progress
            updated.completedDate = date
            
            return updated
        }        
    }
    
    func computeProgress(for challenge: Challenge, workouts: [Workout]) -> (Double, Date?) {
        
        let sortedWorkouts = workouts.sorted { $0.date < $1.date }

        switch challenge.challengeType {
            
        case .distance(let target):
            var total: Double = 0
            
            for workout in sortedWorkouts {
                total += workout.distance ?? 0
                if total >= target {
                    return (1.0, workout.date)
                }
            }
            
            return (min(total / target, 1.0), nil)

        case .runs(let target):
            if sortedWorkouts.count >= target {
                return (1.0, sortedWorkouts[target - 1].date)
            }
            return (Double(sortedWorkouts.count) / Double(target), nil)

        case .elevation(let target):
            for workout in sortedWorkouts {
                if (workout.elevation ?? 0) >= target {
                    return (1.0, workout.date)
                }
            }
            return (0, nil)

        case .singleRun(let target):
            for workout in sortedWorkouts {
                if (workout.distance ?? 0) >= target {
                    return (1.0, workout.date)
                }
            }
            return (0, nil)

        case .streak(let target):
            guard !sortedWorkouts.isEmpty else { return (0, nil) }
            
            let uniqueDays = Set(
                workouts.map { Calendar.current.startOfDay(for: $0.date).stripped }
            ).sorted()
            var streak = 1
            
            for i in 1..<uniqueDays.count {
                let previous = uniqueDays[i - 1]
                let current = uniqueDays[i]
                
                let diff = Calendar.current.dateComponents([.day], from: previous, to: current).day ?? 0

                if diff == 1 {
                    streak += 1
                    
                    if streak >= target {
                        return (1.0, current)
                    }
                } else {
                    streak = 1
                }
            }
            
            return (Double(streak) / Double(target), nil)

        case .duration:
            return (0, nil)
        }
    }
}
