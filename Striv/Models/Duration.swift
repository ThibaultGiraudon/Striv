//
//  Duration.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/01/2026.
//

import Foundation
import SwiftData
  
/// Represents a time duration in hours, minutes, and seconds.
///
/// `Duration` is designed to store and manipulate workout durations.
/// It is compatible with SwiftData (`@Model`) and can be persisted locally.
///
/// Provides convenience properties for:
/// - Total seconds
/// - Human-readable string representation (`label`)
@Model
final class Duration: Equatable, Hashable {
    
    /// Number of hours.
    var hours: Int
    
    /// Number of minutes (0–59).
    var minutes: Int
    
    /// Number of seconds (0–59).
    var seconds: Int
    
    /// Total duration in seconds.
    var totalSeconds: Int
    
    /// Returns a formatted string `"H:MM:SS"` for display purposes.
    var label: String {
        String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// Initializes a `Duration` from a total number of seconds.
    ///
    /// - Parameter time: Total time in seconds.
    /// Example: `Duration(3672)` → 1 hour, 1 minute, 12 seconds
    init(_ time: Int) {
        self.hours = time / 3600
        self.minutes = (time % 3600) / 60
        self.seconds = time % 60
        self.totalSeconds = time
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Duration, rhs: Duration) -> Bool {
        lhs.totalSeconds == rhs.totalSeconds
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(totalSeconds)
    }
}
