//
//  SplitsCard.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI

struct SplitsCard: View {
    let workout: Workout
    var body: some View {
        VStack {
            HStack {
                Text("Splits")
                Spacer()
            }
            .font(.title2.bold())
            
            Grid {
                GridRow {
                    Text("Km")
                    Text("Allure")
                    Spacer()
                    Text("Élev.")
                    Text("FC")
                }
                .bold()
                ForEach(workout.splits.sorted(by: { $0.index < $1.index }), id: \.self) { split in
                    GridRow {
                        Text("\(split.km, specifier: "%0.1f")")
                        Text(split.pace.shortLabel)
                        Spacer()
                        Text("\(split.elevation)")
                        Text("\(split.hr)")
                    }
                }
            }
        }
        .cardStyle()
    }
}
