//
//  Coordinate.swift
//  Striv
//
//  Created by Thibault Giraudon on 10/03/2026.
//

import SwiftUI
import SwiftData

/// Represents a GPS coordinate captured during a workout.
///
/// `Coordinate` is used to store the latitude, longitude, and timestamp
/// of a point along the route of a running session. Coordinates are
/// linked to a `Workout` via a SwiftData relationship.
///
/// This model can be persisted locally and is essential for:
/// - Mapping the running route
/// - Calculating distances and altitudes
/// - Performing route-based analyses
@Model
final class Coordinate {
    
    /// Latitude in decimal degrees.
    var latitude: Double
    
    /// Longitude in decimal degrees.
    var longitude: Double
    
    /// Timestamp when this coordinate was recorded.
    var timestamp: Date

    /// Creates a new `Coordinate`.
    ///
    /// - Parameters:
    ///   - latitude: Latitude in decimal degrees.
    ///   - longitude: Longitude in decimal degrees.
    ///   - timestamp: Date and time the coordinate was recorded.
    init(latitude: Double, longitude: Double, timestamp: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
}
