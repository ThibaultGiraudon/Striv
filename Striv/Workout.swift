//
//  Workout.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation

typealias Workouts = [Workout]

struct Workout: Identifiable {
    let id = UUID()
    var date: Date
    var distance: Double?
    var duration: Duration
    var hr: Double?
    var kcal: Double?
    var elevation: Double?
    
    struct Duration {
        var hours: Int
        var minutes: Int
        var seconds: Int
        
        init(_ time: Int) {
            self.hours = time / 3600
            self.minutes = (time % 3600) / 60
            self.seconds = time % 60
        }
    }
}
