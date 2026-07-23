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
    let downSampled: [MetricSampleEntity]
    @State private var selectedTime: Double?
    var selectedMetricSample: MetricSampleEntity? {
        guard let selectedTime else {
            return nil
        }
        return downSampled.min {
            abs($0.time - selectedTime) < abs($1.time - selectedTime)
        }
    }
    
    init(series: MetricSeriesEntity) {
        self.series = series
        self.downSampled = series.samples.sorted(by: { $0.time < $1.time }).downSample(maxDisplayPoints: 50)
    }
    
    var body: some View {
        
        if series.type == .pace {
            PaceCharts(series: series)
        } else {
            
            let maxTime = downSampled.last?.time ?? 0
            
            let minValue = downSampled.map(\.value).min() ?? 0
            let maxValue = downSampled.map(\.value).max() ?? 0
            
            Chart {
                ForEach(downSampled) { sample in
                    
                    if let selectedMetricSample {
                        RuleMark(
                            x: .value("Time", selectedMetricSample.time)
                        )
                        .foregroundStyle(.white.opacity(0.3))
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            Text("\(selectedMetricSample.value, specifier: "%0.0f") \(series.type.shortUnit)")
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.ultraThinMaterial)
                                        .stroke(series.type.color, lineWidth: 1)
                                }
                        }
                    }
                    
                    LineMark(
                        x: .value("Time", sample.time),
                        y: .value(
                            series.type.title,
                            sample.value
                        )
                    )
                    .foregroundStyle(series.type.color)
                    
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
            .chartXSelection(value: $selectedTime)
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
    MetricsCharts(series: MetricSeriesEntity(type: .elevation, samples: [
        .init(time: 0, value: 545),
        .init(time: 20, value: 550),
        .init(time: 40, value: 555),
        .init(time: 60, value: 545),
        .init(time: 80, value: 535),
        .init(time: 100, value: 525),
        .init(time: 120, value: 545),
        .init(time: 140, value: 565),
        .init(time: 160, value: 555),
    ]))
}
