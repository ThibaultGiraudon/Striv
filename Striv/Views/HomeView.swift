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
    @StateObject private var nextRaceVM = NextRaceViewModel()
    
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
                .accessibilityHint("Double tap pour modifier l'objectif")
                
                
                Text("Prochaine course")
                    .font(.title.bold())
                NavigationLink {
                    NextRaceFormView(nextRaceVM: nextRaceVM)
                } label: {
                    NextRaceView(nextRaceVM: nextRaceVM)
                        .padding(.bottom)
                }
                .accessibilityHint("Double tap pour ajouter ta prochaine course")
                
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
                    .accessibilityHint("Double tap pour voir les détails de la course")
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
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Bouton")
                            .accessibilityHint("Double tap pour importer ta première course")
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Label("Paramètres", systemImage: "gear")
                }
                .tint(.primaryText)
                .accessibilityHint("Double tap pour ouvrir les paramètres")
            }
        }
        .navigationTitle("Accueil")
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
    @Previewable @StateObject var errorPresenter = ErrorPresenter()
    NavigationStack {
        HomeView(workoutsVM: .init(healthKitHelper: HealthKitHelper(), errorPresenter: errorPresenter), dashboardVM: .init())
    }
}
