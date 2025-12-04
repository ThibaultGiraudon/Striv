//
//  RunDetailView.swift
//  Striv
//
//  Created by Thibault Giraudon on 04/12/2025.
//

import SwiftUI

struct RunDetailView: View {
    var workout: Workout
    var body: some View {
        VStack {
            RouteMapView(coordinates: workout.coordinates)
        }
        .navigationTitle(workout.date.toString(format: "dd MMM. YYYY"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RunDetailView(workout: Workout(date: .now, distance: 12129, duration: .init(4333), hr: 171, kcal: 949, elevation: 275, coordinates: []))
    }
}
