//
//  ContentView.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import SwiftUI
import SwiftData

// TODO: ajouter decompte avant prochaine course ex: 35 jours avant "Marathon de saint tropez"

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject var workoutsVM: WorkoutsViewModel = .init()
    @StateObject var dashboardVM: DashboardViewModel = .init()
    @StateObject var runnerProfileVM: RunnerProfileViewModel = .init()
    @StateObject var targetVM: TargetViewModel = .init()
    @StateObject var widgetDataVM: WidgetDataViewModel = .init()
    
    @State private var didRun: Bool = false
    
    @Query(sort: [SortDescriptor(\Workout.date, order: .reverse)]) private var workouts: Workouts
    @Query private var profiles: [RunnerProfile]

    var body: some View {
        TabView {
            Tab("Accueil", systemImage: "house.fill") {
                NavigationStack {
                    HomeView(workoutsVM: workoutsVM, dashboardVM: dashboardVM)
                }
            }

            Tab("Stats", systemImage: "list.bullet.clipboard.fill") {
                NavigationStack {
                    AllStatsView(dashboardVM: dashboardVM)
                }
            }
            
            Tab("Objectif", systemImage: "trophy.fill") {
                NavigationStack {
                    DefineGoalView(runnerProfileVM: runnerProfileVM)
                }
            }

//            Tab("Challenges", systemImage: "trophy.fill") {
//                NavigationStack {
//                    ChallengesView()
//                }
//            }
            
            Tab("Courses", systemImage: "figure.run") {
                NavigationStack {
                    RunsListView(workoutsVM: workoutsVM, targetVM: targetVM, dashboardVM: dashboardVM)
                }
            }
        }
        .onAppear {
            guard !didRun else { return }
            didRun = true
            workoutsVM.setContext(context: modelContext)
            workoutsVM.setRunnerProfileVM(runnerProfileVM)
            runnerProfileVM.setContext(context: modelContext)
            runnerProfileVM.createProfileIfNeeded()
            Task {
                let snapshot = workouts
                await workoutsVM.processNewWorkout(snapshot)
            }
            let lastRun = workouts.first
            var prs: [PR] = []
            
            if let profile = profiles.first {
                for (_, pr) in profile.prs {
                    let newPR = PR(title: pr.prDistance.title, value: Duration(Int(pr.time)).longLabel, distance: pr.prDistance.meters)
                    prs.append(newPR)
                }
            }

            let widgetData = WidgetData(weeklyGoal: targetVM.distanceTarget, weeklyProgress: dashboardVM.stats.currentWeek.totalDistance, lastRunDistance: lastRun?.distance ?? 0, lastRunDuration: lastRun?.duration.longLabel ?? "", lastRunDate: lastRun?.date ?? Date.now, lastRunPace: lastRun?.pace.label ?? "", streak: dashboardVM.stats.currentStreak, prs: prs)
            
            widgetDataVM.saveWidgetData(widgetData)
        }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    ContentView()
        .modelContainer(for: Workout.self, inMemory: true)
        .modelContainer(for: Duration.self, inMemory: true)
        .modelContainer(for: Coordinate.self, inMemory: true)
}
