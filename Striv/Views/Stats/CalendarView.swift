//
//  CalendarView.swift
//  Striv
//
//  Created by Thibault Giraudon on 28/02/2026.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @State private var date: Date = .now
    @Query(sort: [SortDescriptor(\Workout.date, order: .reverse)]) private var workouts: Workouts
    
    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: .init(), count: 7)) {
                ForEach(generateDays(for: date), id: \.self) { day in
                    Text("\(day.day)")
                        .padding(5)
                        .foregroundStyle(workoutExist(for: day) ? Color.background : Color.primaryText)
                        .bold()
                        .background {
                            if workoutExist(for: day) {
                                Circle()
                                    .foregroundStyle(Color.primaryText)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        .padding(.vertical, 10)
                        .opacity(day.month == date.month ? 1 : 0.6)
                }
            }
            
            HStack {
                Button {
                    date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Text(date.toString(format: "MMMM yyyy"))
                
                Button {
                    date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.customPrimary)
        }
        .foregroundStyle(Color.primaryText)
    }
    
    func generateDays(for month: Date) -> [Date] {
        var days: [Date] = []
        
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: month) else {
            return []
        }
        
        var currentDay = monthInterval.start
        currentDay = currentDay.firstDayOfWeek
        
        while currentDay < monthInterval.end {
            days.append(currentDay)
            currentDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDay) ?? .now
        }
        
        return days
    }
    
    func workoutExist(for date: Date) -> Bool {
        workouts.first(where: {$0.date.stripped == date.stripped}) != nil
    }
}

#Preview {
    CalendarView()
}
