//
//  WidgetDataViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/04/2026.
//

import Foundation
import Combine
import WidgetKit
import StrivShared

class WidgetDataViewModel: ObservableObject {
    func saveWidgetData(_ data: WidgetData) {
        let defaults = UserDefaults(suiteName: "group.striv")
        let encoded = try? JSONEncoder().encode(data)
        defaults?.set(encoded, forKey: "widgetData")
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func buildWidgetData(workouts: Workouts, profiles: [RunnerProfile], targetVM: TargetViewModel, dashboardVM: DashboardViewModel) -> WidgetData {
        let lastRun = workouts.first
        var prs: [PR] = []
        
        if let profile = profiles.first {
            for (_, pr) in profile.prs {
                let newPR = PR(title: pr.prDistance.title, value: Duration(Int(pr.time)).longLabel, distance: pr.prDistance.meters)
                prs.append(newPR)
            }
        }
        
        let voiceOverLabels: WidgetData.VoiceOverLabels = .init(
            distance: ((lastRun?.distance ?? 0)/1000).roundedText(to: 2),
            duration: lastRun?.duration.voiceOverLabel ?? "",
            date: lastRun?.date.formatted(format: "dd MMMM YYYY") ?? "",
            pace: lastRun?.pace.shortLabel ?? ""
        )

        let widgetData = WidgetData(weeklyGoal: targetVM.distanceTarget, weeklyProgress: dashboardVM.stats.currentWeek.totalDistance, lastRunDistance: lastRun?.distance ?? 0, lastRunDuration: lastRun?.duration.longLabel ?? "", lastRunDate: lastRun?.date ?? Date.now, lastRunPace: lastRun?.pace.label ?? "", voiceOverLabels: voiceOverLabels, streak: dashboardVM.stats.currentStreak, prs: prs)
        
        return widgetData
    }
}
