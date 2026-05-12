//
//  WidgetData.swift
//  StrivShared
//
//  Created by Thibault Giraudon on 12/05/2026.
//

import Foundation

public struct WidgetData: Codable {
    public let weeklyGoal: Int
    public let weeklyProgress: Double
    
    public let lastRunDistance: Double
    public let lastRunDuration: String
    public let lastRunDate: Date
    public let lastRunPace: String
    
    public let streak: Int
    
    public let prs: [PR]
    
    public init(weeklyGoal: Int, weeklyProgress: Double, lastRunDistance: Double, lastRunDuration: String, lastRunDate: Date, lastRunPace: String, streak: Int, prs: [PR]) {
        self.weeklyGoal = weeklyGoal
        self.weeklyProgress = weeklyProgress
        self.lastRunDistance = lastRunDistance
        self.lastRunDuration = lastRunDuration
        self.lastRunDate = lastRunDate
        self.lastRunPace = lastRunPace
        self.streak = streak
        self.prs = prs
    }
}
