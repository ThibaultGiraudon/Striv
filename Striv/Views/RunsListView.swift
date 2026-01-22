//
//  RunsListView.swift
//  Striv
//
//  Created by Thibault Giraudon on 04/12/2025.
//

import SwiftUI

struct RunsListView: View {
    @ObservedObject var workoutsVM: WorkoutsViewModel
    var body: some View {
        List(workoutsVM.workouts) { workout in
            NavigationLink {
                RunDetailView(workout: workout, workoutsVM: workoutsVM)
            } label: {
                RunRowView(workout: workout)
            }
        }
        .navigationTitle("All runs")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Download", systemImage: "arrow.down.circle") {
                    Task {
                        await workoutsVM.fetchWorkouts()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RunsListView(workoutsVM: .init())
    }
}
