//
//  MonthlyStat.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/04/2026.
//

import Foundation

struct MonthlyStat {
    let startOfMonth: Date
    let distance: Double
    let count: Int
    let duration: TimeInterval
    let elevation: Double
    
    let distanceChange: Double?
}
