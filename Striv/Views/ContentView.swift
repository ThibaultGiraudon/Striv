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
        Group {
            if #available(iOS 26.0, *) {
                TabView {
                    Tab("Accueil", systemImage: "house.fill") {
                        HomeView(workoutsVM: workoutsVM, dashboardVM: dashboardVM)
                    }

                    Tab("Stats", systemImage: "list.bullet.clipboard.fill") {
                        AllStatsView(dashboardVM: dashboardVM)
                    }

                    Tab("Objectif", systemImage: "trophy.fill") {
                        DefineGoalView(runnerProfileVM: runnerProfileVM)
                    }

                    Tab("Courses", systemImage: "figure.run") {
                        RunsListView(workoutsVM: workoutsVM, targetVM: targetVM, dashboardVM: dashboardVM)
                    }
                }
            } else {
                TabView {

                    NavigationStack {
                        HomeView(workoutsVM: workoutsVM, dashboardVM: dashboardVM)
                    }
                    .tabItem { Label("Accueil", systemImage: "house.fill") }

                    NavigationStack {
                        AllStatsView(dashboardVM: dashboardVM)
                    }
                    .tabItem { Label("Stats", systemImage: "list.bullet.clipboard.fill") }

                    NavigationStack {
                        DefineGoalView(runnerProfileVM: runnerProfileVM)
                    }
                    .tabItem { Label("Objectif", systemImage: "trophy.fill") }

                    NavigationStack {
                        RunsListView(
                            workoutsVM: workoutsVM,
                            targetVM: targetVM,
                            dashboardVM: dashboardVM
                        )
                    }
                    .tabItem { Label("Courses", systemImage: "figure.run") }
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
            
            let widgetData = widgetDataVM.buildWidgetData(
                workouts: workouts,
                profiles: profiles,
                targetVM: targetVM,
                dashboardVM: dashboardVM
            )
            
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
