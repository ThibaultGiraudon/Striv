//
//  MetricsOverlayChartView.swift
//  Striv
//
//  Created by Thibault Giraudon on 22/07/2026.
//

import SwiftUI
import Charts

struct MetricsOverlayChartView: View {
    var workout: Workout
    @State private var primarySeries: MetricSeriesEntity?
    @State private var secondarySeries: MetricSeriesEntity?
    @State private var selectedTime: Double?
    var selectedPrimarySample: MetricSampleEntity? {
        guard let selectedTime else {
            return nil
        }
        return primarySeries?.samples.min {
            abs($0.time - selectedTime) < abs($1.time - selectedTime)
        }
    }
    var selectedSecondarySample: MetricSampleEntity? {
        guard let selectedTime else {
            return nil
        }
        return secondarySeries?.samples.min {
            abs($0.time - selectedTime) < abs($1.time - selectedTime)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("Graphique 1", selection: $primarySeries) {
                    ForEach(workout.metricsSeries) { series in
                        Text(series.type.title)
                            .tag(series)
                    }
                }
                .tint(primarySeries?.type.color)
                Spacer()
                Picker("Graphique 2", selection: $secondarySeries) {
                    ForEach(workout.metricsSeries.filter({ $0.id != primarySeries?.id })) { series in
                        Text(series.type.title)
                            .tag(series)
                    }
                }
                .tint(secondarySeries?.type.color)
            }
            if let primarySeries, let secondarySeries {
                ZStack(alignment: .center) {
                    let primarySamples = primarySeries.samples.sorted(by: { $0.time < $1.time }).downSample(maxDisplayPoints: 100)
                    let maxTime: Double = primarySamples.last?.time ?? 0
                    
                    let primaryMinValue = primarySamples.map(\.value).min() ?? 0
                    let primaryMaxValue = primarySamples.map(\.value).max() ?? 0
                    
                    
                    let secondarySamples = secondarySeries.samples.sorted(by: { $0.time < $1.time }).downSample(maxDisplayPoints: 100)
                    
                    let secondaryMinValue = secondarySamples.map(\.value).min() ?? 0
                    let secondaryMaxValue = secondarySamples.map(\.value).max() ?? 0
                    
                    Chart {
                        if let selectedPrimarySample, let selectedSecondarySample {
                            RuleMark(x: .value("Time", selectedPrimarySample.time))
                                .foregroundStyle(.white.opacity(0.3))
                                .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                    VStack {
                                        let primaryPace: Workout.Pace = .init(pace: selectedPrimarySample.value)
                                        let secondaryPace: Workout.Pace = .init(pace: selectedSecondarySample.value)
                                        
                                        let primaryString: String = primarySeries.type == .pace ? primaryPace.shortLabel : selectedPrimarySample.value.roundedText(to: 0)
                                        let secondaryString: String = secondarySeries.type == .pace ? secondaryPace.shortLabel : selectedSecondarySample.value.roundedText(to: 0)
                                        
                                        Text("\(primaryString) \(primarySeries.type.shortUnit)")
                                            .foregroundStyle(primarySeries.type.color)
                                        Text("\(secondaryString) \(secondarySeries.type.shortUnit)")
                                            .foregroundStyle(secondarySeries.type.color)
                                    }
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(.ultraThinMaterial)
                                                .stroke(.white, lineWidth: 1)
                                        }
                                }
                        }
                        
                        MetricChartMarks(series: primarySeries, samples: primarySamples)
                        
                        MetricChartMarks(series: secondarySeries, samples: secondarySamples)
                    }
                    .chartXSelection(value: $selectedTime)
                    .chartForegroundStyleScale([
                        MetricType.pace.title: MetricType.pace.gradient,
                        MetricType.heartRate.title: MetricType.heartRate.gradient,
                        MetricType.elevation.title: MetricType.elevation.gradient,
                        MetricType.power.title: MetricType.power.gradient,
                        MetricType.cadence.title: MetricType.cadence.gradient
                    ])
                    .chartXScale(domain: 0...maxTime)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisTick()
                            
                            if let normalized = value.as(Double.self) {
                                AxisValueLabel {
                                    Text("\(denormalize(normalized, min: primarySeries.type == .pace ? primaryMaxValue : primaryMinValue, max: primarySeries.type == .pace ? primaryMinValue : primaryMaxValue), specifier: "%.0f")")
                                }
                            }
                        }
                        
                        AxisMarks(position: .trailing) { value in
                            AxisGridLine()
                            AxisTick()
                            
                            if let normalized = value.as(Double.self) {
                                AxisValueLabel {
                                    Text("\(denormalize(normalized, min: secondarySeries.type == .pace ? secondaryMaxValue : secondaryMinValue, max: secondarySeries.type == .pace ? secondaryMinValue : secondaryMaxValue), specifier: "%.0f")")
                                }
                            }
                        }
                    }
                    .frame(height: 400)
                }
                .padding()
            }
        }
        .onAppear {
            primarySeries = workout.metricsSeries.first(where: { $0.type == .pace })
            secondarySeries = workout.metricsSeries.first(where: { $0.type == .elevation })
        }
    }
    
    func denormalize(
        _ normalized: Double,
        min: Double,
        max: Double
    ) -> Double {
        min + normalized * (max - min)
    }
}

struct MetricChartMarks: ChartContent {

    let series: MetricSeriesEntity
    let samples: [MetricSampleEntity]

    var body: some ChartContent {

        ForEach(samples) { sample in
            AreaMark(
                x: .value("Time", sample.time),
                yStart: .value("Min", 0),
                yEnd: .value(series.type.title, sample.normalizedValue)
            )
            .foregroundStyle(by: .value("Type", series.type.title))
            
            LineMark(
                x: .value("Time", sample.time),
                y: .value(series.type.title, sample.normalizedValue)
            )
            .foregroundStyle(by: .value("Type", series.type.title))
            .lineStyle(.init(lineWidth: 2))
        }
    }
}

#Preview {
    MetricsOverlayChartView(workout: .init(id: UUID(), date: .now, duration: .init(3600)))
}

