//
//  TargetView.swift
//  Striv
//
//  Created by Thibault Giraudon on 16/03/2026.
//

import SwiftUI

struct TargetView: View {
    @ObservedObject var dashboardVM: DashboardViewModel
    @ObservedObject var targetVM: TargetViewModel
    
    var currentWeekDistance: Double {
        self.dashboardVM.stats.currentWeek.totalDistance
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(currentWeekDistance.roundedText(to: 1)) km")
                .font(.system(size: 50).bold())
            
            Text("Distance totale")
                .font(.title)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 5) {
                CustomProgressView(value: currentWeekDistance, total: Double(targetVM.distanceTarget))
                Text("\(targetVM.distanceTarget) km")
                    .font(.title.bold())
                    .foregroundStyle(.primaryText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background {
                        Capsule()
                            .foregroundStyle(.quinary)
                            .glassContainer()
                    }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .foregroundStyle(.primaryText)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [.customPink, .customPink], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.1))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Objectif hébdomadaire \(currentWeekDistance.roundedText(to: 1))km sur \(targetVM.distanceTarget)")
    }
}

#Preview {
    TargetView(dashboardVM: .init(), targetVM: .init())
        .padding()
        .background(Color.background)
}
