//
//  Date+formatted.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

extension Date {
    /// Converts a `Date` to `String`
    ///
    /// - Parameter format: A `String` representing the format into converts the date.
    /// - Returns: A `String` equal at the initial date.
    func formatted(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        
        return dateFormatter.string(from: self)
    }
}
