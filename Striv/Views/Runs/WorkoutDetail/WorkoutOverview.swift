//
//  WorkoutOverview.swift
//  Striv
//
//  Created by Thibault Giraudon on 22/07/2026.
//

import SwiftUI

struct CardModifier: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(color)
            }
    }
}

extension View {
    func cardStyle(_ color: Color = .customPrimary) -> some View {
        modifier(CardModifier(color: color))
    }
}

struct WorkoutOverview: View {
    let workout: Workout
    @StateObject private var workoutDetailVM: WorkoutDetailViewModel
    @Environment(\.modelContext) var modelContext
    
    init(workout: Workout, errorPresenter: ErrorPresenter) {
        self.workout = workout
        self._workoutDetailVM = StateObject(wrappedValue: .init(workout: workout, healthKitHelper: HealthKitHelper(), errorPresenter: errorPresenter))
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: .init(), count: 2)) {
                statRow(systemImage: "clock.fill", title: "Temps", value: workout.duration.label, metric: .time)
                statRow(systemImage: "figure.run", title: "Rythme", value: workout.pace.shortLabel, metric: .pace)
                statRow(systemImage: "suit.heart.fill", title: "Fréquence", value: workout.hr, metric: .heartRate)
                statRow(systemImage: "flame.fill", title: "Calorie", value: workout.kcal, metric: .calories)
                statRow(systemImage: "mountain.2.fill", title: "Dénivelé", value: workout.elevation, metric: .elevation)
                statRow(systemImage: "bolt.fill", title: "Puissance", value: workout.power, metric: .power)
                statRow(systemImage: "shoeprints.fill", title: "Cadence", value: workout.cadence, metric: .cadence)
            }
            .cardStyle()
            .task {
                workoutDetailVM.setContext(context: modelContext)
                await workoutDetailVM.prepareData()
            }

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
            
            if let paceSeries = workoutDetailVM.paceSeries, let bestSplit = workoutDetailVM.bestSplit {
                VStack {
                    HStack {
                        Text("Allure")
                        Spacer()
                    }
                    .font(.title2.bold())
                    
                    PaceCharts(series: paceSeries)
                    LazyVGrid(columns: Array(repeating: .init(), count: 2)) {
                        statRow(systemImage: "figure.run", title: "Allure moy.", value: workout.pace.shortLabel, metric: .pace)
                        statRow(systemImage: "figure.run", title: "Meilleur km", value: bestSplit.shortLabel, metric: .pace)
                    }
                }
                .cardStyle()
            }
            
            if let hrSeries = workoutDetailVM.heartRateSeries, let maxHr = workoutDetailVM.maxHeartRate {
                VStack {
                    HStack {
                        Text("Fréquence cardiaque")
                        Spacer()
                    }
                    .font(.title2.bold())
                    
                    MetricsCharts(series: hrSeries)
                    LazyVGrid(columns: Array(repeating: .init(), count: 2)) {
                        statRow(systemImage: "suit.heart.fill", title: "FC moy.", value: workout.hr, metric: .heartRate)
                        statRow(systemImage: "figure.run", title: "FC max.", value: maxHr, metric: .heartRate)
                    }
                }
                .cardStyle()
            }
            
            if let elevationSeries = workoutDetailVM.elevationSeries, let minElevation = workoutDetailVM.minElevation, let maxElevation = workoutDetailVM.maxElevation {
                VStack {
                    HStack {
                        Text("Dénivelé")
                        Spacer()
                    }
                    .font(.title2.bold())
                    
                    MetricsCharts(series: elevationSeries)
                    LazyVGrid(columns: Array(repeating: .init(), count: 2)) {
                        statRow(systemImage: "mountain.2.fill", title: "Dénivelé +", value: workout.elevation, metric: .elevation)
                        statRow(systemImage: "mountain.2.fill", title: "Altitude max.", value: maxElevation, metric: .elevation)
                        statRow(systemImage: "mountain.2.fill", title: "Altitude min.", value: minElevation, metric: .elevation)
                    }
                }
                .cardStyle()
            }
            
            if let powerSeries = workoutDetailVM.powerSeries {
                VStack {
                    HStack {
                        Text("Puissance")
                        Spacer()
                    }
                    .font(.title2.bold())
                    
                    MetricsCharts(series: powerSeries)
                    HStack {
                        statRow(systemImage: "bolt.fill", title: "Puissance", value: workout.power, metric: .power)
                        Spacer()
                    }
                }
                .cardStyle()
            }
            
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
    
    @ViewBuilder
    func statRow(systemImage: String, title: String, value: StatDisplayable?, metric: MetricType) -> some View{
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

#Preview {
    ScrollView {
        WorkoutOverview(workout: Workout(id: UUID(), date: .now, distance: 12129, duration: .init(4400), hr: 171, kcal: 949, elevation: 275, cadence: 151, power: 221), errorPresenter: .init())
    }
}
