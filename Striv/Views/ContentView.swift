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

    var body: some View {
        TabView {
            Tab("Stats", systemImage: "list.bullet.clipboard.fill") {
                NavigationStack {
                    AllStatsView(workoutsVM: workoutsVM)
                }
            }

            Tab("Challenges", systemImage: "trophy.fill") {
                NavigationStack {
                    ChallengesView()
                }
            }
            
            Tab("Runs", systemImage: "figure.run") {
                NavigationStack {
                    RunsListView(workoutsVM: workoutsVM)
                }
            }
        }
        .onAppear {
            workoutsVM.setContext(context: modelContext)
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
