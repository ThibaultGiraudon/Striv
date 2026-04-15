//
//  HomeView.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/01/2026.
//

import SwiftUI
import Charts
import SwiftData


struct HomeView: View {
    @Query(sort: [SortDescriptor(\Workout.date, order: .reverse)]) private var workouts: Workouts
    @ObservedObject var workoutsVM: WorkoutsViewModel
    @ObservedObject var dashboardVM = DashboardViewModel()
    @StateObject private var targetVM = TargetViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                
                Text("Ma progression")
                    .font(.title.bold())
                NavigationLink {
                    TargetFormView(targetVM: targetVM)
                } label: {
                    TargetView(dashboardVM: dashboardVM, targetVM: targetVM)
                        .padding(.bottom)
                }
                
                
//                RunProgressView(dashboardVM: dashboardVM)
//                    .padding(.bottom)
                
                Text("Cette semaine")
                    .font(.title.bold())
                StatsView(title: "", stats: dashboardVM.stats.currentWeek)
                    .padding(.bottom)
                
                Text("Dernière course")
                    .font(.title.bold())
                if let lastRun = workouts.first {
                    NavigationLink {
                        RunDetailView(workout: lastRun, workoutsVM: workoutsVM)
                    } label: {
                        RunRowView(workout: lastRun)
                            .foregroundStyle(.primaryText)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.customPrimary)
                            }
                    }
                } else {
                    Button {
                        Task {
                            await workoutsVM.fetchWorkoutsSummary()
                        }
                    } label: {
                            VStack(alignment: .center) {
                                Text("Importer ma première course")
                                    .font(.title2)
                                Image(systemName: "arrow.down.circle")
                            }
                            .foregroundStyle(.primaryText)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.customPrimary)
                            }
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("Accueil")
        .padding(.horizontal)
        .background(Color.background)
        .onChange(of: workouts) { _, workouts in
            dashboardVM.load(with: workouts)
        }
        .task {
            dashboardVM.load(with: workouts)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(workoutsVM: .init(), dashboardVM: .init())
    }
}
