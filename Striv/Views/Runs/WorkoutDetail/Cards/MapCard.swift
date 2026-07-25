//
//  MapCard.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI

struct MapCard: View {
    let workout: Workout
    
    var body: some View {
        GeometryReader { geo in
            if !workout.coordinates2d.isEmpty {
                NavigationLink {
                    RouteMapView(coordinates: workout.coordinates2d)
                        .accessibilityHidden(true)
                } label: {
                    RouteMapView(coordinates: workout.coordinates2d)
                        .disabled(true)
                        .accessibilityHidden(true)
                        .frame(width: geo.size.width, height: geo.size.width)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .aspectRatio(contentMode: .fill)
    }
}
