//
//  RunnerProfile.swift
//  Striv
//
//  Created by Thibault Giraudon on 10/04/2026.
//

import Foundation
import SwiftData

enum GoalType: String, CaseIterable, Codable {
    case distance = "Distance"
    case time = "Temps"
}

enum PresetDistance: String, Codable, CaseIterable {
    case fiveK
    case tenK
    case halfMarathon
    case marathon
    
    var title: String {
        switch self {
        case .fiveK: return "5 km"
        case .tenK: return "10 km"
        case .halfMarathon: return "Semi-marathon"
        case .marathon: return "Marathon"
        }
    }
    
    var meters: Double {
        switch self {
        case .fiveK: return 5_000
        case .tenK: return 10_000
        case .halfMarathon: return 21_097.5
        case .marathon: return 42_195
        }
    }
    
}

enum DistanceType: Codable, Equatable, Hashable {
    case preset(PresetDistance)
    case custom(Double)
    
    var meters: Double {
        switch self {
        case .preset(let preset): return preset.meters
        case .custom(let value): return value
        }
    }
    
    var title: String {
        switch self {
        case .preset(let preset):
            return preset.title
            
        case .custom:
            return "Distance personnalisée"
        }
    }
    
    static var allCases: [DistanceType] {
        PresetDistance.allCases.map { .preset($0) }
    }
}

struct Goal: Codable {
    var type: GoalType
    
    var distance: DistanceType
    
    var targetTime: Int?
}

struct PRResult: Codable {
    let distance: Double
    let time: TimeInterval
    let workoutId: UUID
    let date: Date
    let prDistance: PresetDistance
}

@Model
class RunnerProfile {
    @Attribute(.unique) var id: UUID
    
    var goal: Goal
    
    /*private*/ var prsData: Data?
    
    @Transient
    var prs: [PresetDistance: PRResult] {
        guard let data = prsData else {
            return [:]
        }
        guard let decoded = try? JSONDecoder().decode([PresetDistance: PRResult].self, from: data) else {
            return [:]
        }
        
        return decoded
    }
    
    init(goal: Goal) {
        self.id = UUID()
        self.goal = goal
        self.prsData = nil
    }
    
    func goalDescription() -> String {
        switch goal.type {
        case .distance:
            return "Objectif: terminer \(goal.distance.title) mètres"
        case .time:
            return "Objectif: courir \(goal.distance.title) mètres en \(goal.targetTime ?? 0) minutes"
        }
    }
    
    func encodePRs(with newprs: [PresetDistance: PRResult]) {
        prsData = (try? JSONEncoder().encode(newprs)) ?? Data()
    }
}
