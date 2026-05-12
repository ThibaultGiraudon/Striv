//
//  ContentView.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import SwiftUI
import SwiftData
import StrivShared

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var errorPresenter: ErrorPresenter
    @StateObject var workoutsVM: WorkoutsViewModel
    @StateObject var dashboardVM: DashboardViewModel
    @StateObject var runnerProfileVM: RunnerProfileViewModel
    @StateObject var targetVM: TargetViewModel
    @StateObject var widgetDataVM: WidgetDataViewModel
    
    @State private var didRun: Bool = false
    @State private var activError: String?
    @State private var presentAlert: Bool = false
    
    @Query(sort: [SortDescriptor(\Workout.date, order: .reverse)]) private var workouts: Workouts
    @Query private var profiles: [RunnerProfile]

    init(errorPresenter: ErrorPresenter) {
        self._workoutsVM = StateObject(wrappedValue: WorkoutsViewModel(healthKitHelper: HealthKitHelper(), errorPresenter: errorPresenter))
        self._dashboardVM = StateObject(wrappedValue: .init())
        self._runnerProfileVM = StateObject(wrappedValue: .init(errorPresenter: errorPresenter))
        self._targetVM = StateObject(wrappedValue: .init())
        self._widgetDataVM = StateObject(wrappedValue: .init())
    }
    
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
        .alert(item: $errorPresenter.error) { error in
            Alert(
                title: Text("Erreur"),
                message: Text(error.errorDescription ?? ""),
                dismissButton: .default(Text("OK")) {
                    errorPresenter.error = nil
                }
            )
        }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    @Previewable @StateObject var errorPresenter = ErrorPresenter()
    ContentView(errorPresenter: errorPresenter)
        .modelContainer(for: Workout.self, inMemory: true)
        .modelContainer(for: Duration.self, inMemory: true)
        .modelContainer(for: Coordinate.self, inMemory: true)
        .modelContainer(for: RunnerProfile.self, inMemory: true)
        .modelContainer(for: RunSampleEntity.self, inMemory: true)
        .environmentObject(errorPresenter)
}
