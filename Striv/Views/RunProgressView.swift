//
//  RunProgressView.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/04/2026.
//

import SwiftUI

// TODO: ajouter un écran de détail et d'explication

struct RunProgressView: View {
    @ObservedObject var dashboardVM: DashboardViewModel
    var progression: Double {
        let monthlyStats = self.dashboardVM.stats.monthly
        guard monthlyStats.count > 2 else {
            return 0
        }
        return monthlyStats[monthlyStats.count - 2].distanceChange ?? 0
    }
    var body: some View {
        HStack(alignment: .bottom) {
            Text(" \(progression >= 0 ? "+ " : "")\(progression.roundedText(to: 0)) %")
                .font(.system(size: 50).bold())
                .foregroundStyle(progression >= 0 ? .teal : .red)
            Text("vs mois dernier")
                .font(.title)
                .foregroundStyle(.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(progression >= 0 ? .teal : .red).opacity(0.1))
        }
    }
}

#Preview {
    RunProgressView(dashboardVM: .init())
}
