//
//  Date+.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

extension Date {
    
    private var calendar: Calendar {
        var cal = Calendar(identifier: .iso8601)
        cal.firstWeekday = 2 // Monday
        return cal
    }

    var hour: Int {
        calendar.component(.hour, from: self)
    }
    
    var day: Int {
        calendar.component(.day, from: self)
    }
    
    var weekOfYear: Int {
        calendar.component(.weekOfYear, from: self)
    }
    
    var month: Int {
        calendar.component(.month, from: self)
    }
    
    var year: Int {
        calendar.component(.year, from: self)
    }
    
    var startOfDay: Date {
        calendar.startOfDay(for: self)
    }
    
    var firstDayOfWeek: Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        ?? self
    }
    
    var firstDayOfMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: self))
        ?? self
    }
    
    var firstDayOfYear: Date {
        calendar.date(from: calendar.dateComponents([.year], from: self))
        ?? self
    }
}
