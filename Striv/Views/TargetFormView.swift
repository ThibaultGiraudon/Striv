//
//  TargetFormView.swift
//  Striv
//
//  Created by Thibault Giraudon on 16/03/2026.
//

import SwiftUI

struct TargetFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var targetVM: TargetViewModel
    var body: some View {
        NavigationStack {
            Form {
                Section("Objectif hebdomadire") {
                    TextField("Distance", value: $targetVM.distanceTarget, format: .number)
                        .keyboardType(.numberPad)
                    TextField("Nombre de course", value: $targetVM.numberTarget, format: .number)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Objectifs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Valider") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TargetFormView(targetVM: .init())
}
