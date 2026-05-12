//
//  Date+formatted.swift
//  StrivShared
//
//  Created by Thibault Giraudon on 12/05/2026.
//


import Foundation

extension Date {
    /// Converts a `Date` to `String`
    ///
    /// - Parameter format: A `String` representing the format into converts the date.
    /// - Returns: A `String` equal at the initial date.
    public func formatted(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        
        return dateFormatter.string(from: self)
    }
}
