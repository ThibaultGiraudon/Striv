//
//  NextRaceView.swift
//  Striv
//
//  Created by Thibault Giraudon on 20/04/2026.
//

import SwiftUI

struct NextRaceView: View {
    @ObservedObject var nextRaceVM: NextRaceViewModel
    var body: some View {
        if nextRaceVM.title.isEmpty {
            Text("Ajoute la date de ta prochaine course")
                .font(.title3.bold())
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.customPrimary)
            }
            .foregroundStyle(Color.primaryText)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text(nextRaceVM.date.formatted(format: "dd MMMM yyyy"))
                    .foregroundStyle(.secondary)
                Text(nextRaceVM.title)
                    .font(.title.bold())
                HStack(spacing: 0) {
                    Text("dans ")
                    Text(nextRaceVM.formatTime(for: nextRaceVM.date))
                        .foregroundStyle(.teal)
                        .fontWeight(.bold)
                    Spacer()
                }
                .font(.title3)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.customPrimary)
            }
            .foregroundStyle(Color.primaryText)
        }
    }
}

#Preview {
    NextRaceView(nextRaceVM: .init())
}
