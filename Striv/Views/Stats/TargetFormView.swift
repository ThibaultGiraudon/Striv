//
//  TargetFormView.swift
//  Striv
//
//  Created by Thibault Giraudon on 16/03/2026.
//

import SwiftUI

struct TargetFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var distance: Double = 20.0
    @ObservedObject var targetVM: TargetViewModel
    var body: some View {
            VStack(alignment: .leading) {
                Text("Objectif de distance hebdomadaire")
                    .font(.title.bold())
                Divider()
                Text("Définis la distance que tu souhaites parcourir chaque semaine.")
                Text("Choisis une distance cohérente pour te motiver.")
                Text("Cela t'aidera à structurer ton entrainement.")
                Divider()
                VStack(alignment: .center) {
                    HStack(alignment: .bottom) {
                        Text("\(distance.rounded(.down).roundedText(to: 0))")
                            .font(.system(size: 70).bold())
                        Text("km")
                            .font(.system(size: 50).bold())
                    }
                    .foregroundStyle(.teal)
                    
                    Text("par semaine")
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                    
                    Slider(value: $distance, in: 0...150)
                        .tint(.teal)
                    
                    HStack {
                        Text("0 km")
                        Spacer()
                        Text("150 km")
                    }
                    
                    Spacer()
                    
                    Text(feedbackText)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Button {
                    targetVM.setDistanceTarget(to: Int(distance.rounded(.down)))
                    dismiss()
                } label: {
                    Text("Enregistrer")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.teal)
                        }
                }
                
            }
        .padding()
        .background(Color.background)
        .foregroundStyle(.primaryText)
        .onAppear {
            distance = Double(targetVM.distanceTarget)
        }
    }
    
    var feedbackText: String {
        switch distance {
        case 0..<10:
            return "Objectif léger, idéal pour une reprise."
        case 10..<30:
            return "Bon objectif pour maintenir une activité régulière."
        case 30..<70:
            return "Objectif ambitieux, bon volume d'entraînement."
        default:
            return "Volume élevé, assure-toi d'avoir une récupération adaptée."
        }
    }
    
}

#Preview {
    TargetFormView(targetVM: .init())
}
