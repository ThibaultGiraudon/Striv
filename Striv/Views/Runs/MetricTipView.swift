//
//  MetricTipView.swift
//  Striv
//
//  Created by Thibault Giraudon on 06/05/2026.
//

import SwiftUI

struct MetricTipView: View {
    @Environment(\.dismiss) var dismiss
    var metric: MetricType
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: metric.icon)
                    Text(metric.title)
                    Spacer()
                }
                .font(.largeTitle)
                Text(metric.definition)
                    .padding(.vertical)
                HStack(alignment: .top) {
                    Image(systemName: "lightbulb.circle")
                    VStack(alignment: .leading) {
                        Text("Pourquoi c'est utile ?")
                        Text(metric.whyItMatters)
                    }
                }
                HStack(alignment: .top) {
                    Image(systemName: "exclamationmark.circle")
                    VStack(alignment: .leading) {
                        Text("Valeurs typiques")
                        ForEach(metric.typicalValues, id: \.0) {
                            (title, value) in
                            HStack {
                                Text(title)
                                Spacer()
                                Text(value)
                            }
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.teal.opacity(0.5))
                }
                .padding(.vertical)
            }
        }
        .padding()
//        .background {
//            Color.background
//                .ignoresSafeArea()
//        }
        .foregroundStyle(Color.primaryText)
        .font(.title3)
    }
}

#Preview {
    MetricTipView(metric: .cadence)
}
