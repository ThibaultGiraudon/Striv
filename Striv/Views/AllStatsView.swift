//
//  AllStatsView.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/04/2026.
//

import SwiftUI
import SwiftData

struct AllStatsView: View {
    @Query(sort: [SortDescriptor(\Workout.date, order: .reverse)]) private var workouts: Workouts
    @ObservedObject var dashboardVM: DashboardViewModel
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center) {
                Text("Statistiques")
                    .foregroundStyle(.primaryText)
                    .font(.title.bold())
                HStack(alignment: .bottom) {
                    Text(dashboardVM.stats.global.totalDistance.roundedText(to: 0))
                        .font(.system(size: 70).bold())
                    Text("km")
                        .font(.system(size: 60).bold())
                }
                
                Text("Distance total")
                    .font(.title)
                    .foregroundStyle(.secondary)
                
                StreakView(currentStreak: dashboardVM.stats.currentStreak)
                    .padding(.bottom, 10)
                
                StatsView(title: "", stats: dashboardVM.stats.global)
                    .padding(.bottom, 10)
                
                RunChartsView(dashboardVM: dashboardVM)
                    .padding(.bottom, 10)
                
                CalendarView()
            }
        }
        .padding()
        .foregroundStyle(.primaryText)
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
    AllStatsView(dashboardVM: .init())
}
