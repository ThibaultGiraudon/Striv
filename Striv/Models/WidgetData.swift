//
//  WidgetData.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/04/2026.
//

import Foundation

struct WidgetData: Codable {
    let weeklyGoal: Int
    let weeklyProgress: Double
    
    let lastRunDistance: Double
    let lastRunDuration: String
    let lastRunDate: Date
    let lastRunPace: String
    
    let streak: Int
    
    let prs: [PR]
}

struct PR: Codable {
    let title: String
    let value: String
    let distance: Double
}
