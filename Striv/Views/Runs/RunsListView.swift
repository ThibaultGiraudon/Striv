//
//  RunsListView.swift
//  Striv
//
//  Created by Thibault Giraudon on 04/12/2025.
//

import SwiftUI
import SwiftData

struct RunsListView: View {
    @ObservedObject var workoutsVM: WorkoutsViewModel
    @Query(sort: [SortDescriptor(\Workout.date, order: .reverse)]) private var workouts: Workouts
    var body: some View {
        List(workouts) { workout in
            NavigationLink {
                RunDetailView(workout: workout, workoutsVM: workoutsVM)
            } label: {
                RunRowView(workout: workout)
            }
            .listRowBackground(Color.customPrimary)
        }
        .navigationTitle("All runs")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Download", systemImage: "arrow.down.circle") {
                    Task {
                        await workoutsVM.fetchWorkoutsSummary()
                    }
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button("CPT", systemImage: "trophy.fill") {
                    let prs = workoutsVM.computePRs(with: workouts)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.background)
    }
}

#Preview {
    NavigationStack {
        RunsListView(workoutsVM: .init())
    }
}
