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
    @State private var isShowingTargetSheet: Bool = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                GeometryReader { geo in
                    let width = geo.size.width
                    ScrollView(.horizontal) {
                        HStack {
                            StreakView(currentStreak: dashboardVM.stats.currentStreak)
                                .frame(width: width)
                            
                            TargetView(dashboardVM: dashboardVM, targetVM: targetVM)
                                .frame(width: width)
                            
                            Button("Définir un objectif") {
                                isShowingTargetSheet.toggle()
                            }
                            .font(.title3.bold())
                            .tint(.teal)
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .frame(width: width)
                        }
                        .scrollTargetLayout()
                        .padding()
                    }
                    .scrollTargetBehavior(.viewAligned)
                }
                .frame(height: 100)
                    
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
            .sheet(isPresented: $isShowingTargetSheet) {
                TargetFormView(targetVM: targetVM)
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
