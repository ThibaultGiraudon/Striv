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
                .font(.system(size: 65).bold())
            
            Text("Distance totale")
                .font(.title)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 5) {
                CustomProgressView(value: currentWeekDistance, total: Double(targetVM.distanceTarget))
                Text("\(targetVM.distanceTarget) km")
                    .font(.title.bold())
                    .foregroundStyle(.primaryText)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 5)
                    .background {
                        Capsule()
                            .glassEffect()
                    }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [.gray, .teal], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.2))
        }
    }
}

#Preview {
    TargetView(dashboardVM: .init(), targetVM: .init())
        .padding()
        .background(Color.background)
}
