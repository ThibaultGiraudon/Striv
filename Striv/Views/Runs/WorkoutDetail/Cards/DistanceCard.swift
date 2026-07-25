//
//  DistanceCard.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI

struct DistanceCard: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            Text("\((workout.distance ?? 0) / 1000, specifier: "%.2f")km")
                .font(.switzer(size: 66, weight: .bold))
                .italic()
            Spacer()
        }
    }
}
