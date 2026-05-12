//
//  RunsListView.swift
//  Striv
//
//  Created by Thibault Giraudon on 04/12/2025.
//

import SwiftUI
import SwiftData
import StrivShared

struct RunsListView: View {
    @ObservedObject var workoutsVM: WorkoutsViewModel
    @ObservedObject var targetVM: TargetViewModel
    @ObservedObject var dashboardVM: DashboardViewModel
    @StateObject private var widgetDataVM: WidgetDataViewModel = .init()
    @Query(sort: [SortDescriptor(\Workout.date, order: .reverse)]) private var workouts: Workouts
    @Query private var profiles: [RunnerProfile]
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
                    Task { @MainActor in
                        await workoutsVM.fetchWorkoutsSummary()
                        
                        let widgetData = widgetDataVM.buildWidgetData(
                            workouts: workouts,
                            profiles: profiles,
                            targetVM: targetVM,
                            dashboardVM: dashboardVM
                        )
                        
                        widgetDataVM.saveWidgetData(widgetData)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.background)
    }
}

#Preview {
    @Previewable @StateObject var errorPresenter = ErrorPresenter()
    NavigationStack {
        RunsListView(workoutsVM: .init(healthKitHelper: HealthKitHelper(), errorPresenter: errorPresenter), targetVM: .init(), dashboardVM: .init())
    }
}
