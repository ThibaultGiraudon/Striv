//
//  PresetDistance.swift
//  Striv
//
//  Created by Thibault Giraudon on 26/07/2026.
//

import Foundation

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
