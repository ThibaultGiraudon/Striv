//
//  Duration.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/01/2026.
//

import Foundation
import SwiftData
  
@Model
final class Duration: Equatable, Hashable {
    var hours: Int
    var minutes: Int
    var seconds: Int
    var totalSeconds: Int
    
    var label: String {
        String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    
    init(_ time: Int) {
        self.hours = time / 3600
        self.minutes = (time % 3600) / 60
        self.seconds = time % 60
        self.totalSeconds = time
    }
}
