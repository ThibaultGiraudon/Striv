//
//  Date+.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

extension Date {
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
    
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
    
    var week: Int {
        Calendar.current.component(.weekOfYear, from: self)
    }
    
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    var stripped: Date {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        
        return Calendar.current.date(from: components)!
    }
    
    var firstDayOfWeek: Date {
        let components = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        
        return Calendar.current.date(from: components)!
    }
}
