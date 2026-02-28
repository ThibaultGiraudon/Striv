//
//  HomeView.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/01/2026.
//

import SwiftUI
import Charts


struct AllStatsView: View {
    @ObservedObject var workoutsVM: WorkoutsViewModel
    
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
                            Text("\(workoutsVM.currentStreak)")
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
                            Text("\(workoutsVM.longestStreak)")
                                .foregroundStyle(Color.background)
                                .font(.largeTitle.bold())
                                .padding(.bottom, 5)
                        }
                        Text("Longest Streak")
                            .bold()
                    }
                }
                
                StatsView(title: "All time", stats: workoutsVM.globalStats)
                StatsView(title: "Last 4 weeks", stats: workoutsVM.lastFourWeeksStats)
                StatsView(title: "Current week", stats: workoutsVM.currentWeekStats)
                
                Chart {
                    ForEach(workoutsVM.weeklyStats, id: \.self) { weekStat in
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
                
                CalendarView(workouts: $workoutsVM.workouts)
                
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Stats")
        .background(Color.background)
    }
}

#Preview {
    var workoutsVM = WorkoutsViewModel()
    workoutsVM.workouts = [
        Workout(id: UUID(), date: .now, distance: 12700, duration: .init(3600), coordinates: [], altitudes: []),
        Workout(id: UUID(), date: Date().addingTimeInterval(-604800 * 2), distance: 21800, duration: .init(3600), coordinates: [], altitudes: []),
    ]
    return  NavigationStack { AllStatsView(workoutsVM: workoutsVM) }
}
