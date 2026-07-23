//
//  PaceCharts.swift
//  Striv
//
//  Created by Thibault Giraudon on 22/07/2026.
//

import SwiftUI
import Charts

struct PaceCharts: View {
    var series: MetricSeriesEntity
    
    var body: some View {
        Text("\(series.type.title)")

        let samples = series.samples.sorted(by: { $0.time < $1.time }).downSample(maxDisplayPoints: 100)

        let maxTime = samples.last?.time ?? 0
        
        let minValue = samples.map(\.value).min() ?? 0
        let maxValue = min(12.0, samples.map(\.value).max() ?? 12.0)

        Chart {
            ForEach(samples) { sample in
                AreaMark(
                    x: .value("Time", sample.time),
                    yStart: .value("Min", maxValue),
                    yEnd: .value(
                        series.type.title,
                        sample.value
                    )
                )
                .foregroundStyle(series.type.gradient)
            }
        }
        .chartXScale(domain: 0...maxTime)
        .chartYScale(
            domain: [maxValue, minValue]
        )
        .chartYAxis {
            AxisMarks(preset: .aligned, position: .trailing, values: [maxValue, minValue])
        }
        .frame(height: 400)
    }
}

#Preview {
    PaceCharts(
        series: MetricSeriesEntity(
            type: .pace,
            samples: [
                MetricSample(
                    time: 0,
                    value: 6.2,
                    normalizedValue: 6.2
                ),
                MetricSample(
                    time: 30,
                    value: 5.9,
                    normalizedValue: 5.9
                ),
                MetricSample(
                    time: 60,
                    value: 5.7,
                    normalizedValue: 5.7
                ),
                MetricSample(
                    time: 90,
                    value: 5.5,
                    normalizedValue: 5.5
                ),
                MetricSample(
                    time: 120,
                    value: 5.3,
                    normalizedValue: 5.3
                ),
                MetricSample(
                    time: 150,
                    value: 5.1,
                    normalizedValue: 5.1
                ),
                MetricSample(
                    time: 180,
                    value: 5.4,
                    normalizedValue: 5.4
                ),
                MetricSample(
                    time: 210,
                    value: 5.8,
                    normalizedValue: 5.8
                ),
                MetricSample(
                    time: 240,
                    value: 6.1,
                    normalizedValue: 6.1
                ),
                MetricSample(
                    time: 270,
                    value: 5.6,
                    normalizedValue: 5.6
                ),
                MetricSample(
                    time: 300,
                    value: 5.2,
                    normalizedValue: 5.2
                ),
                MetricSample(
                    time: 330,
                    value: 4.9,
                    normalizedValue: 4.9
                ),
                MetricSample(
                    time: 360,
                    value: 5.0,
                    normalizedValue: 5.0
                ),
                MetricSample(
                    time: 390,
                    value: 5.5,
                    normalizedValue: 5.5
                ),
                MetricSample(
                    time: 420,
                    value: 6.0,
                    normalizedValue: 6.0
                )
            ]
        )
    )
}
