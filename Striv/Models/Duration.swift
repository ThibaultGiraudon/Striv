//
//  Duration.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/01/2026.
//

import Foundation
    
struct Duration {
    var hours: Int
    var minutes: Int
    var seconds: Int
    var totalSeconds: Int
    
    init(_ time: Int) {
        self.hours = time / 3600
        self.minutes = (time % 3600) / 60
        self.seconds = time % 60
        self.totalSeconds = time
    }
}
