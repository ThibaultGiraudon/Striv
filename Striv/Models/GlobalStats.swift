//
//  GlobalStats.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

struct GlobalStats {
    let totalDistance: Double
    let totalDuration: Duration
    let totalElevation: Double
    let count: Int
    
    init(totalDistance: Double = 0.0, totalDuration: Duration = .init(0), totalElevation: Double = 0.0, count: Int = 0) {
        self.totalDistance = totalDistance
        self.totalDuration = totalDuration
        self.totalElevation = totalElevation
        self.count = count
    }
}
