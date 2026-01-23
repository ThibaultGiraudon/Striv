//
//  HomeView.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/01/2026.
//

import SwiftUI
import Charts

struct HomeView: View {
    @ObservedObject var workoutsVM: WorkoutsViewModel
    
    var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .month, value: -3, to: endDate)!
        return start...endDate
    }
    
    @State var endDate: Date = .now
    var body: some View {
        VStack {
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
            .frame(height: 400)
        }
        .navigationTitle("Home")
    }
}

#Preview {
    var workoutsVM = WorkoutsViewModel()
    workoutsVM.workouts = [
        Workout(date: .now, distance: 12700, duration: .init(3600), coordinates: [], altitudes: []),
        Workout(date: Date().addingTimeInterval(-604800 * 2), distance: 21800, duration: .init(3600), coordinates: [], altitudes: []),
    ]
    return HomeView(workoutsVM: workoutsVM)
}
