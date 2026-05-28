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
    @State private var selectedWeek: WeeklyStat? = nil

    var body: some View {
        VStack(alignment: .leading) {
            if let selectedWeek {
                VStack(alignment: .leading) {
                    Text("\(selectedWeek.label)")
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Distance")
                                .font(.footnote)
                            Text("\(selectedWeek.distance.roundedText(to: 2)) km")
                                .bold()
                        }
                        VStack(alignment: .leading) {
                            Text("Temps")
                                .font(.footnote)
                            Text(selectedWeek.duration.label)
                                .bold()
                        }
                        VStack(alignment: .leading) {
                            Text("Dénivelé")
                                .font(.footnote)
                            Text("\(selectedWeek.elevation.roundedText(to: 0)) m")
                                .bold()
                        }
                    }
                }
            }
            
            Chart {
                ForEach(dashboardVM.stats.weekly, id: \.self) { weekStat in
                    PointMark(
                        x: .value("Week", weekStat.startOfWeek),
                        y: .value("Distance", weekStat.distance)
                    )
                    .foregroundStyle(selectedWeek == weekStat ? .white : .teal)
                    
                    LineMark(
                        x: .value("Week", weekStat.startOfWeek),
                        y: .value("Distance", weekStat.distance)
                    )
                    .foregroundStyle(.teal)
                    
                    AreaMark(
                        x: .value("Week", weekStat.startOfWeek),
                        y: .value("Distance", weekStat.distance)
                    )
                    .foregroundStyle(LinearGradient(colors: [.teal, .clear], startPoint: .top, endPoint: .bottom))
                    
                    if selectedWeek == weekStat {
                        RuleMark(x: .value("Week", weekStat.startOfWeek))
                    }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 60 * 60 * 24 * 7 * 11)
            .chartXScale(domain: (dashboardVM.stats.weekly.first?.startOfWeek ?? Date.now)...Date.now)
            .chartScrollPosition(initialX: Date.now)
            .chartGesture { chart in
                SpatialTapGesture()
                    .onEnded { value in
                        let result = chart.value(at: value.location, as: (Date, Double).self)
                        selectedWeek = dashboardVM.stats.weekly.first(where: {$0.startOfWeek == result?.0.firstDayOfWeek})
                    }
            }
            .frame(height: 200)
            .accessibilityHidden(true)
        }
        .onAppear {
            self.selectedWeek = dashboardVM.stats.weekly.last
        }
    }
}

#Preview {
    RunChartsView(dashboardVM: .init())
}
