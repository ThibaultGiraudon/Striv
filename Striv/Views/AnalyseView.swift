//
//  AnalyseView.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/12/2025.
//

import SwiftUI

struct AnalyseView: View {
    var response: Analyse?
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Material.ultraThinMaterial)
                .ignoresSafeArea()
            if let response {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(response.sections, id: \.self) { section in
                         VStack(alignment: .leading) {
                             Text(section.title)
                                 .font(.title2)
                             ForEach(section.items, id: \.self) { item in
                                 Text(item)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    .padding()
                }
            } else {
                ProgressView()
            }
        }
    }
}

#Preview {
    AnalyseView(response: Analyse(sections: [
        .init(
            title: "Résumé",
            items: ["Cette sortie de 73 minutes et 12 km a combiné un travail d'endurance avec un dénivelé notable, sollicitant le système cardiovasculaire de manière intense."]),
        .init(
            title: "Ce que cette séance a travaillé",
            items: [
                "Endurance de base**: La durée de 73 minutes contribue à améliorer la capacité à maintenir l'effort sur la durée.",
                "Résistance musculaire**: Les 275m de dénivelé positif ont renforcé les muscles spécifiques à la course en côte.",
                "Capacité aérobie**: La fréquence cardiaque élevée indique une sollicitation importante du système cardiovasculaire."
                ]
            ),
        .init(
            title: "Points de vigilance",
            items: [
                "Intensité perçue/Fréquence cardiaque**: Une FC moyenne de 171 bpm pour un rythme de 6:02/km est élevée, suggérant un effort soutenu plutôt qu'une séance facile d'endurance fondamentale.",
                "Cadence**: Une cadence de 151 pas/minute est relativement basse, pouvant potentiellement affecter l'efficacité."
                ]
            ),

            .init(
                title: "Conseil clé pour la prochaine séance",
                items: ["Pour les sorties d'endurance, vise délibérément une fréquence cardiaque plus basse pour optimiser le développement de ton fond."]
                )
        ]))
}
