//
//  OverlayCard.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI

struct OverlayCard: View {
    let workout: Workout
    
    var body: some View {
        VStack {
            HStack {
                Text("Superposition")
                Spacer()
            }
            .font(.title2.bold())
            
            MetricsOverlayChartView(workout: workout)
        }
        .cardStyle()
    }
}
