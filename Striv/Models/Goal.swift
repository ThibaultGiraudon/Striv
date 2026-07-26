//
//  Goal.swift
//  Striv
//
//  Created by Thibault Giraudon on 26/07/2026.
//

import Foundation
import Combine
import SwiftData

@Model
class Goal {
    var id: UUID
    var distance: PresetDistance
    var time: Double
    var isMain: Bool
    
    init(id: UUID = UUID(), distance: PresetDistance, time: Double, isMain: Bool) {
        self.id = id
        self.distance = distance
        self.time = time
        self.isMain = isMain
    }
}
