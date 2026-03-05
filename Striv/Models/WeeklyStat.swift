//
//  WeeklyStat.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

struct WeeklyStat: Identifiable, Hashable {
    var id = UUID()
    let startOfWeek: Date
    var endOfWeek: Date {
        startOfWeek.addingTimeInterval(3600 * 24 * 6)
    }
    var label: String {
        startOfWeek.toString(format: "d MMM") + "-" + endOfWeek.toString(format: "d MMM")
    }
    
    let distance: Double
    let count: Int
    let duration: Duration
    let elevation: Double
    
    init(id: UUID = UUID(), startOfWeek: Date = .now, distance: Double = 0.0, count: Int = 0, duration: Duration = .init(0), elevation: Double = 0.0) {
        self.id = id
        self.startOfWeek = startOfWeek
        self.distance = distance
        self.count = count
        self.duration = duration
        self.elevation = elevation
    }
}
