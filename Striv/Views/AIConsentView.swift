//
//  AIConsentView.swift
//  Striv
//
//  Created by Thibault Giraudon on 11/05/2026.
//


import SwiftUI

struct AIConsentView: View {
    
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // MARK: - Header
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundStyle(.blue)
                        }
                        .accessibilityElement(children: .ignore)
                        
                        VStack(spacing: 12) {
                            Text("Analyse IA de vos séances")
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)
                            
                            Text("Striv peut utiliser l’intelligence artificielle de Google Gemini pour analyser vos séances de course et générer des conseils personnalisés.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // MARK: - Content
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        consentRow(
                            icon: "figure.run",
                            title: "Données utilisées",
                            description: "Durée, allure, distance, fréquence cardiaque, cadence et dénivelé."
                        )
                        
                        consentRow(
                            icon: "lock.shield",
                            title: "Vie privée",
                            description: "Aucune donnée directement identifiable comme votre nom ou votre email n’est envoyée à l’IA."
                        )
                        
                        consentRow(
                            icon: "slider.horizontal.3",
                            title: "Contrôle utilisateur",
                            description: "Vous pouvez désactiver l’analyse IA à tout moment dans les réglages."
                        )
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                
                // MARK: - Actions
                
                VStack(spacing: 12) {
                    
                    Button {
                        onAccept()
                        dismiss()
                    } label: {
                        Text("Autoriser l’analyse IA")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(5)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button {
                        onDecline()
                        dismiss()
                    } label: {
                        Text("Continuer sans IA")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    
                    Link(
                        "Politique de confidentialité",
                        destination: URL(string: "https://thibaultgiraudon.github.io/striv-privacy/")!
                    )
                    .font(.footnote)
                    .padding(.top, 4)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Components

private extension AIConsentView {
    
    @ViewBuilder
    func consentRow(
        icon: String,
        title: String,
        description: String
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)
                .accessibilityElement(children: .ignore)
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AIConsentView(
        onAccept: {},
        onDecline: {}
    )
}
