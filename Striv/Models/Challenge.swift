//
//  Challenge.swift
//  Striv
//
//  Created by Thibault Giraudon on 18/03/2026.
//

import Foundation

enum ChallengeType {
    case distance(total: Double)
    case duration(total: Int)
    case runs(number: Int)
    case elevation(total: Double)
    case singleRun(distance: Double)
    case streak(number: Int)
}

struct Challenge: Identifiable {
    var id = UUID()
    let title: String
    let description: String
    let challengeType: ChallengeType
    var progression: Double = 0.0
    var completedDate: Date?
    var isCompleted: Bool {
        completedDate == nil ? false : true
    }
}
