//
//  AIInfoView.swift
//  Striv
//
//  Created by Thibault Giraudon on 06/05/2026.
//

import SwiftUI

struct AIInfoView: View {
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    header
                    
                    section(
                        title: "Comment ça marche",
                        icon: "brain.head.profile",
                        content: "Haaku utilise des modèles d’intelligence artificielle pour analyser tes courses et générer des insights personnalisés à partir de tes données (allure, fréquence cardiaque, distance…)."
                    )
                    
                    section(
                        title: "Limites",
                        icon: "exclamationmark.triangle",
                        content: "Les analyses sont générées automatiquement et peuvent contenir des erreurs ou approximations. Elles dépendent aussi de la qualité des données (GPS, capteurs…)."
                    )
                    
                    section(
                        title: "Bon usage",
                        icon: "checkmark.seal",
                        content: "Utilise ces informations comme un guide pour progresser, pas comme une vérité absolue. Croise toujours avec ton ressenti."
                    )
                }
                .padding()
            }
        }
    }
}

private extension AIInfoView {
    
    func section(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.cyan)
                    .accessibilityElement(children: .ignore)
                
                Text(title)
                    .font(.headline)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private extension AIInfoView {
    
    var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(.cyan)
                .accessibilityElement(children: .ignore)
            
            Text("Analyses intelligentes")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Des insights générés automatiquement pour t’aider à progresser.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    AIInfoView()
}
