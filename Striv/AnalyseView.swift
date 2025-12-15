//
//  AnalyseView.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/12/2025.
//

import SwiftUI

struct AnalyseView: View {
    var response: String
    var responses: [String] {
        response.split(separator: "\n\n").map { subString in
            String(subString)
        }
    }
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Material.ultraThinMaterial)
                .ignoresSafeArea()
            if response.isEmpty {
                ProgressView()
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(responses, id: \.self) { paragraph in
                            let sentences: [String] = paragraph.split(separator: "\n").map { String($0) }
                            VStack(alignment: .leading) {
                                ForEach(sentences, id: \.self) { sentence in
                                    let formatedSentence = sentence.starts(with: "### ") ? String(sentence.dropFirst(4)) : sentence
                                    Text(LocalizedStringKey(formatedSentence))
                                        .font(sentence.starts(with: "### ") ? .title2 : .default)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    AnalyseView(response: """
        ### Résumé
        Cette sortie de 73 minutes et 12 km a combiné un travail d'endurance avec un dénivelé notable, sollicitant le système cardiovasculaire de manière intense.

        ### Ce que cette séance a travaillé
        *   **Endurance de base**: La durée de 73 minutes contribue à améliorer la capacité à maintenir l'effort sur la durée.
        *   **Résistance musculaire**: Les 275m de dénivelé positif ont renforcé les muscles spécifiques à la course en côte.
        *   **Capacité aérobie**: La fréquence cardiaque élevée indique une sollicitation importante du système cardiovasculaire.

        ### Points de vigilance
        *   **Intensité perçue/Fréquence cardiaque**: Une FC moyenne de 171 bpm pour un rythme de 6:02/km est élevée, suggérant un effort soutenu plutôt qu'une séance facile d'endurance fondamentale.
        *   **Cadence**: Une cadence de 151 pas/minute est relativement basse, pouvant potentiellement affecter l'efficacité.

        ### Conseil clé pour la prochaine séance
        Pour les sorties d'endurance, vise délibérément une fréquence cardiaque plus basse pour optimiser le développement de ton fond.
        """)
}
