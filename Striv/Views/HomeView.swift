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
                ForEach(workoutsVM.distancePerWeek.filter { dateRange.contains($0.key)}.sorted(by: >), id: \.key) { (date, distance) in
                    LineMark(
                        x: .value("Week", date, unit: .weekOfYear),
                        y: .value("Distance", distance)
                    )
                    .foregroundStyle(.teal)
                AreaMark(
                        x: .value("Week", date, unit: .weekOfYear),
                        y: .value("Distance", distance)
                    )
                .foregroundStyle(LinearGradient(colors: [.teal, .clear], startPoint: .top, endPoint: .bottom))
                
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < 0 {
                            endDate = endDate.addingTimeInterval(86400 * 7 * 4)
                        } else if value.translation.width > 0 {
                            endDate = endDate.addingTimeInterval(86400 * -7 * 4)
                        }
                    }
            )
        }
        .navigationTitle("Home")
        .onAppear {
            print(workoutsVM.distancePerWeek)
        }
    }
}

#Preview {
    var workoutsVM = WorkoutsViewModel()
    workoutsVM.workouts = [
        Workout(date: .now, distance: 12.7, duration: .init(3600), coordinates: [], altitudes: []),
        Workout(date: Date().addingTimeInterval(-604800), distance: 21.8, duration: .init(3600), coordinates: [], altitudes: []),
    ]
    return HomeView(workoutsVM: workoutsVM)
}
