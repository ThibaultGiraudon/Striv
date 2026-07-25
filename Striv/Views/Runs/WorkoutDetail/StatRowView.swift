//
//  StatRowView.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI

struct StatRowView: View {
    var systemImage: String
    var title: String
    var value: StatDisplayable?
    var metric: MetricType
    var body: some View {
        if let value, value.statText != "0" {
            VStack {
                HStack {
                    Image(systemName: systemImage)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                    Text(title)
                }
                Text("\(value.statText) \(metric.shortUnit)")
                    .font(.title2.bold())
            }
            .padding(.vertical)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(metric.valuePlusUnit(value.statText))
        }
    }
}
