//
//  DefineGoalViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 20/04/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class DefineGoalViewModel: ObservableObject {
    
    @Published var goalType: GoalType = .time
    @Published var distanceType: DistanceType = .preset(.marathon)
    @Published var customDistance: Double = 0.0
    @Published var time: Double = 180
    @Published var prs: [PresetDistance: PRResult] = [:]
    
    var profile: RunnerProfile?
    
    var timeBounds: (min: Int, max: Int) {
        let km = distanceType.meters / 1000
        let minPace: Double = 150 + km
        let maxPace: Double = 600
        
        return (Int((minPace * km))/60, Int((maxPace * km))/60)
    }
    
    var formatTime: String {
        let h = Int(time) / 60
        let m = Int(time) % 60
        
        return h > 0 ? "\(h)h\(m<10 ? "0" : "")\(m)" : "\(m) min"
    }
    
    var pace: Workout.Pace {
        Workout.Pace(pace: time / (distanceType.meters / 1000))
    }
    
    var progression: (label: String, feedback: String, state: String, color: Color, image: String) {
        guard let profile,
              let preset = PresetDistance.allCases.first(where: {$0.meters == distanceType.meters}),
              let pr = profile.prs[preset]
        else {
            return ("-", "Non defini", "-", .gray, "minus.circle")
        }
        
        let progression = ((pr.time - (time * 60)) / pr.time) * 100
        let label = String(format: "%@%.0f%%", progression >= 0 ? "+" : "", progression)
        
        switch progression {
        case ...0: return (label, "Défi atteint", "Validé", .green, "checkmark.circle")
        case 0..<10: return (label, "Défi atteignable", "Rapidement", .green, "checkmark.circle")
        case 10..<20: return (label, "Défi modéré", "Réaliste", .yellow, "checkmark.circle")
        case 20..<30: return (label, "Défi ambitieux", "Challengeant", .orange, "minus.circle")
        default: return (label, "Défi exigeant", "Difficile", .red, "xmark.circle")
        }
    }
}
