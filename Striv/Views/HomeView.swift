//
//  HomeView.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/01/2026.
//

import SwiftUI
import Charts
import SwiftData


struct AllStatsView: View {
    @Query(sort: [SortDescriptor(\Workout.date, order: .reverse)]) private var workouts: Workouts
    @ObservedObject var workoutsVM: WorkoutsViewModel
    @StateObject private var dashboardVM = DashboardViewModel()
    
    @State var endDate: Date = .now
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                HStack {
                    VStack {
                        ZStack(alignment: .bottom) {
                            Image(systemName: "flame")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 75)
                                .foregroundStyle(.red)
                            Image(systemName: "flame.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 75)
                                .foregroundStyle(.red)
                            Text("\(dashboardVM.stats.currentStreak)")
                                .foregroundStyle(Color.background)
                                .font(.largeTitle.bold())
                                .padding(.bottom, 5)
                        }
                        Text("Current Streak")
                            .foregroundStyle(.red)
                            .bold()
                    }
                    VStack {
                        ZStack(alignment: .bottom) {
                            Image(systemName: "flame")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 75)
                                .foregroundStyle(Color.primaryText)
                            Image(systemName: "flame.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 75)
                                .foregroundStyle(Color.primaryText)
                            Text("\(dashboardVM.stats.longestStreak)")
                                .foregroundStyle(Color.background)
                                .font(.largeTitle.bold())
                                .padding(.bottom, 5)
                        }
                        Text("Longest Streak")
                            .bold()
                    }
                }
                
                StatsView(title: "All time", stats: dashboardVM.stats.global)
                StatsView(title: "Last 4 weeks", stats: dashboardVM.stats.lastFourWeeks)
                StatsView(title: "Current week", stats: dashboardVM.stats.currentWeek)
                
                Chart {
                    ForEach(dashboardVM.stats.weekly, id: \.self) { weekStat in
                        LineMark(
                            x: .value("Week", weekStat.startOfWeek),
                            y: .value("Distance", weekStat.distance)
                        )
                        .foregroundStyle(.teal)
                        
                        AreaMark(
                            x: .value("Week", weekStat.startOfWeek),
                            y: .value("Distance", weekStat.distance)
                        )
                        .foregroundStyle(LinearGradient(colors: [.teal, .clear], startPoint: .top, endPoint: .bottom))
                        
                    }
                }
                .chartScrollableAxes(.horizontal)
                .chartScrollPosition(initialX: Date.now)
                .frame(height: 400)
                
                CalendarView()
                
            }
            .padding()
            .onChange(of: workouts) { _, workouts in
                dashboardVM.load(with: workouts)
            }
            .task {
                dashboardVM.load(with: workouts)
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Stats")
        .background(Color.background)
    }
}

#Preview {
    NavigationStack {
        AllStatsView(workoutsVM: .init())
    }
}
