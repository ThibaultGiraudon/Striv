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
    @StateObject private var targetVM = TargetViewModel()
    
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
                                    .frame(height: 50)
                                    .foregroundStyle(.red)
                                Image(systemName: "flame.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 50)
                                    .foregroundStyle(.red)
                                Text("\(dashboardVM.stats.currentStreak)")
                                    .foregroundStyle(Color.background)
                                    .font(.title2.bold())
                                    .padding(.bottom, 5)
                            }
                            Text("Current Streak")
                                .foregroundStyle(.red)
                                .bold()
                        }
                        
                        HStack(spacing: 10) {
                            CircleIndicatorView(current: dashboardVM.stats.currentWeek.totalDistance, target: Double(targetVM.distanceTarget), size: 40, lineWidth: 7)
                            VStack(alignment:.leading) {
                                Text("\(targetVM.distanceTarget) km par semaine")
                                    .font(.title2.bold())
                                Text("\(dashboardVM.stats.currentWeek.totalDistance.roundedText(to: 1)) km / \(targetVM.distanceTarget)km")
                            }
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

struct CarouselView: View {
    
    let items = Array(1...10)
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(items, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue)
                        .frame(width: 250, height: 300)
                        .overlay(
                            Text("\(item)")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        )
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 40)
    }
}

#Preview {
    NavigationStack {
        AllStatsView(workoutsVM: .init())
    }
}
