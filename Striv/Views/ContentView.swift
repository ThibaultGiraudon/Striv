//
//  ContentView.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject var workoutsVM: WorkoutsViewModel = .init()
    @StateObject var dashboardVM: DashboardViewModel = .init()
    @StateObject var runnerProfileVM: RunnerProfileViewModel = .init()
    @StateObject var targetVM: TargetViewModel = .init()
    
    @State private var didRun: Bool = false
    
    @Query(sort: [SortDescriptor(\Workout.date, order: .reverse)]) private var workouts: Workouts

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
