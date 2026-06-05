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
    
    public let voiceOverLabels: VoiceOverLabels
    
    public let streak: Int
    
    public let prs: [PR]
    
    public init(weeklyGoal: Int, weeklyProgress: Double, lastRunDistance: Double, lastRunDuration: String, lastRunDate: Date, lastRunPace: String, voiceOverLabels: VoiceOverLabels, streak: Int, prs: [PR]) {
        self.weeklyGoal = weeklyGoal
        self.weeklyProgress = weeklyProgress
        self.lastRunDistance = lastRunDistance
        self.lastRunDuration = lastRunDuration
        self.lastRunDate = lastRunDate
        self.lastRunPace = lastRunPace
        self.voiceOverLabels = voiceOverLabels
        self.streak = streak
        self.prs = prs
    }
    
    public struct VoiceOverLabels: Codable {
        public let distance: String
        public let duration: String
        public let date: String
        public let pace: String
        
        public init(distance: String, duration: String, date: String, pace: String) {
            self.distance = distance
            self.duration = duration
            self.date = date
            self.pace = pace
        }
    }
}
