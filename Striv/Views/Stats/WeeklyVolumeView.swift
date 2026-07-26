//
//  WeeklyVolumeView.swift
//  Striv
//
//  Created by Thibault Giraudon on 28/05/2026.
//

import SwiftUI

struct WeeklyVolumeView: View {
    @ObservedObject var dashboardVM: DashboardViewModel
    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled

    var body: some View {
        VStack(alignment: .leading) {
            Text("Distance hebdomadaire")
                .font(.title)
                .padding(.bottom)
            
            if isVoiceOverEnabled {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(dashboardVM.stats.weekly.sorted { $0.startDate > $1.startDate}, id: \.self) { weekStat in
                            Text("\(weekStat.startDate.formatted(format: "dd MMM")) - \(weekStat.endOfWeek.formatted(format: "dd MMM YYYY")): \(weekStat.distance.roundedText(to: 2))km")
                                .accessibilityLabel(weekStatLabel(weekStat: weekStat))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 150)
            } else {
                RunChartsView(dashboardVM: dashboardVM)
            }
                
        }
        .cardStyle()
    }
    
    func weekStatLabel(weekStat: PeriodicStat) -> String {
        var labels: [String] = []
        
        labels.append("du \(weekStat.startDate.formatted(format: "dd MMMM")) au \(weekStat.endOfWeek.formatted(format: "dd MMMM YYYY"))")
        
        labels.append("distance: \(weekStat.distance.roundedText(to: 1))km")
        
        labels.append("temps: \(weekStat.duration.label)")
        
        labels.append("dénivelé: \(weekStat.elevation.roundedText(to: 0))m")
        
        return labels.joined(separator: ", ")
    }
    
}

#Preview {
    WeeklyVolumeView(dashboardVM: .init())
}
