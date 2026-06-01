//
//  PRsView.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/04/2026.
//

import SwiftUI
import SwiftData

struct PRsView: View {
    @Query private var profiles: [RunnerProfile]
    var body: some View {
        if let profile = profiles.first {
            VStack(alignment: .leading) {
                Text("Records personnels")
                    .font(.title)
                    .padding(.bottom)
                ForEach(profile.prs.sorted(by: { $0.0.meters < $1.0.meters }), id: \.key) { key, pr in
                    HStack {
                        Text(pr.prDistance.title)
                            .font(.title2)
                        Spacer()
                        Text(Duration(Int(pr.time)).longLabel)
                            .font(.title2.bold())
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(pr.prDistance.title) en \(Duration(Int(pr.time)).voiceOverLabel)")
                    Divider()
                }
                if profile.prs.isEmpty {
                    Text("Aucun record personnel pour le moment. Commence à courir pour en établir !")
                        .foregroundStyle(.primaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.customPrimary)
            }
        }
    }
}

#Preview {
    PRsView()
}
