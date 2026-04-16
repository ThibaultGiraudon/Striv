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
            workoutsVM.setContext(context: modelContext)
            workoutsVM.setRunnerProfileVM(runnerProfileVM)
            runnerProfileVM.setContext(context: modelContext)
            runnerProfileVM.createProfileIfNeeded()
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
