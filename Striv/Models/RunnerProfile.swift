//
//  RunnerProfile.swift
//  Striv
//
//  Created by Thibault Giraudon on 10/04/2026.
//

import Foundation
import SwiftData

struct PRResult: Codable {
    let time: TimeInterval
    let workoutId: UUID
    let date: Date
    let prDistance: PresetDistance
}

@Model
class RunnerProfile {
    @Attribute(.unique) var id: UUID
    
    private var prsData: Data?
    
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
    
    init() {
        self.id = UUID()
        self.prsData = nil
    }
    
    func encodePRs(with newprs: [PresetDistance: PRResult]) {
        prsData = (try? JSONEncoder().encode(newprs)) ?? Data()
    }
}
