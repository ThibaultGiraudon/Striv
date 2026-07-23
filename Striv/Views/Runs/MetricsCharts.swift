//
//  MetricsCharts.swift
//  Striv
//
//  Created by Thibault Giraudon on 22/07/2026.
//

import SwiftUI
import Charts

struct MetricsCharts: View {
    var series: MetricSeriesEntity
    var body: some View {
        
        if series.type == .pace {
            PaceCharts(series: series)
        } else {
            Text("\(series.type.title)")
            
            let samples = series.samples.sorted(by: { $0.time < $1.time }).downSample(maxDisplayPoints: 100)
            
            let maxTime = samples.last?.time ?? 0
            
            let minValue = samples.map(\.value).min() ?? 0
            let maxValue = samples.map(\.value).max() ?? 0
            
            Chart {
                ForEach(samples) { sample in
                    AreaMark(
                        x: .value("Time", sample.time),
                        yStart: .value("Min", minValue),
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
                domain: [minValue, maxValue]
            )
            .chartYAxis {
                AxisMarks(preset: .aligned, position: .trailing, values: [minValue, maxValue])
            }
            .frame(height: 400)
        }
    }
}

#Preview {
    MetricsCharts(series: MetricSeriesEntity(type: .distance, samples: []))
}
