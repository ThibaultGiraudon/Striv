//
//  RunChartsView.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/04/2026.
//

import SwiftUI
import Charts

struct RunChartsView: View {
    @ObservedObject var dashboardVM: DashboardViewModel
    @State private var selectedWeek: PeriodicStat? = nil

    private var weeks: [PeriodicStat] {
        dashboardVM.stats.weekly
    }

    var body: some View {
        VStack(alignment: .leading) {

            if let selectedWeek {
                VStack(alignment: .leading) {
                    Text(selectedWeek.label)

                    HStack {
                        metric(title: "Distance",
                               value: "\(selectedWeek.distance.roundedText(to: 2)) km")

                        metric(title: "Temps",
                               value: selectedWeek.duration.label)

                        metric(title: "Dénivelé",
                               value: "\(selectedWeek.elevation.roundedText(to: 0)) m")
                    }
                }
                .sensoryFeedback(.selection, trigger: selectedWeek)
            }

            if weeks.isEmpty {
                Text("Aucune course enregistrée")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            } else {

                let start = weeks.first?.startDate ?? Date()
                let end = weeks.last?.startDate ?? Date()

                Chart {
                    ForEach(weeks, id: \.id) { weekStat in

                        PointMark(
                            x: .value("Week", weekStat.startDate),
                            y: .value("Distance", weekStat.distance)
                        )
                        .foregroundStyle(selectedWeek?.id == weekStat.id ? .white : .customPink)

                        LineMark(
                            x: .value("Week", weekStat.startDate),
                            y: .value("Distance", weekStat.distance)
                        )
                        .foregroundStyle(.customPink)

                        AreaMark(
                            x: .value("Week", weekStat.startDate),
                            y: .value("Distance", weekStat.distance)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.customPink, .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        if selectedWeek?.id == weekStat.id {
                            RuleMark(x: .value("Week", weekStat.startDate))
                        }
                    }
                }
                .chartXScale(domain: safeDateRange(start: start, end: end))
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 60 * 60 * 24 * 7 * 11)
                .chartScrollPosition(initialX: end)
                .chartGesture { chart in
                    SpatialTapGesture()
                        .onEnded { value in
                            guard let result = chart.value(at: value.location, as: (Date, Double).self) else {
                                return
                            }

                            selectedWeek = weeks.first(where: {
                                $0.startDate == result.0.firstDayOfWeek
                            })
                        }
                }

                .frame(height: 200)
                .accessibilityHidden(true)
            }
        }
        .onAppear {
            selectedWeek = weeks.last
        }
    }

    @ViewBuilder
    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)
            Text(value)
                .bold()
        }
    }

    private func safeDateRange(start: Date, end: Date) -> ClosedRange<Date> {
        guard start < end else {
            let now = Date()
            return now...now.addingTimeInterval(1)
        }
        return start...end
    }
}
#Preview {
    RunChartsView(dashboardVM: .init())
}
