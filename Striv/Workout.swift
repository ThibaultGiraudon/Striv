//
//  Workout.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation
import CoreLocation

typealias Workouts = [Workout]

struct Workout: Identifiable {
    let id = UUID()
    var date: Date
    var distance: Double?
    var duration: Duration
    var hr: Double?
    var kcal: Double?
    var elevation: Double?
    var cadence: Double?
    var power: Double?
    var pace: Pace {
        Pace(pace:  Double(duration.totalSeconds / 60) / ((distance ?? 1) / 1000))
    }
    var coordinates: [CLLocationCoordinate2D]
    
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
    
    struct Pace {
        var minutes: Int
        var seconds: Int
        
        init(pace: Double) {
            self.minutes = Int(pace / 1)
            self.seconds = Int(pace.truncatingRemainder(dividingBy: 1) * 60)
        }
    }
}
