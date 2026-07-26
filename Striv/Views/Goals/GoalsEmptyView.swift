//
//  GoalsEmptyView.swift
//  Striv
//
//  Created by Thibault Giraudon on 26/07/2026.
//

import SwiftUI

struct GoalsEmptyView: View {
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .font(.title)
            Text("Définis un objectif principal pour analyser tes courses.")
            Spacer()
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.customPrimary)
                .stroke(.secondary, lineWidth: 1)
        }
    }
}

#Preview {
    GoalsEmptyView()
}
