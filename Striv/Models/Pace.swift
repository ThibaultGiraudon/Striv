//
//  Pace.swift
//  Striv
//
//  Created by Thibault Giraudon on 24/07/2026.
//

import Foundation
import SwiftData

@Model
class Pace: Equatable, Hashable, Comparable {
    static func < (lhs: Pace, rhs: Pace) -> Bool {
        let lhsTotal = lhs.minutes * 60 + lhs.seconds
        
        let rhsTotal = rhs.minutes * 60 + rhs.seconds
        
        return lhsTotal < rhsTotal
    }
    
    var minutes: Int
    var seconds: Int
    
    var label: String { String(format: "%02d'%02d\"/km", minutes, seconds) }
    var shortLabel: String { String(format: "%02d'%02d\"", minutes, seconds) }
    
    init(pace: Double) {
        self.minutes = Int(pace / 1)
        self.seconds = Int(pace.truncatingRemainder(dividingBy: 1) * 60)
    }
}
