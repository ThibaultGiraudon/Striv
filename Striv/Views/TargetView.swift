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
    var body: some View {
        HStack(spacing: 20) {
            CircleIndicatorView(current: dashboardVM.stats.currentWeek.totalDistance, target: Double(targetVM.distanceTarget), size: 40, lineWidth: 7)
            VStack(alignment:.leading) {
                Text("\(targetVM.distanceTarget) km par semaine")
                    .font(.title2.bold())
                Text("\(dashboardVM.stats.currentWeek.totalDistance.roundedText(to: 1)) km / \(targetVM.distanceTarget)km")
            }
            Spacer()
        }
    }
}

#Preview {
    TargetView(dashboardVM: .init(), targetVM: .init())
}
