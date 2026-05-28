//
//  SettingsView.swift
//  Striv
//
//  Created by Thibault Giraudon on 11/05/2026.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("aiConsentAccepted")
    private var aiConsentAccepted = false
    
    @State private var showPrivacyPolicy = false
    
    var body: some View {
        NavigationStack {
            List {
                aiSection
                legalSection
            }
            .navigationTitle("Confidentialité")
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }
}
// MARK: - Sections
private extension SettingsView {
    
    var aiSection: some View {
        Section {
            Toggle(isOn: $aiConsentAccepted) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Analyses IA")
                        .font(.headline)
                    
                    Text("Autorise Striv à utiliser Google Gemini pour analyser vos séances de course.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Données potentiellement envoyées", systemImage: "lock.shield")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Durée de séance")
                Text("Allure moyenne")
                Text("Distance")
                Text("Fréquence cardiaque")
                Text("Dénivelé")
                Text("Cadence")
                Text("Puissance")
                
                Text("Aucune donnée personnelle identifiable (nom, email, identifiant utilisateur) n’est envoyée à l’IA.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Intelligence artificielle")
        } footer: {
            Text("Vous pouvez désactiver l’analyse IA à tout moment.")
        }
    }
    
    var legalSection: some View {
        Section {
            Button {
                showPrivacyPolicy = true
            } label: {
                Label("Politique de confidentialité", systemImage: "doc.text")
            }
            
            Link(destination: URL(string: "https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/2-5-flash-lite?hl=fr")!) {
                Label("Confidentialité Google Gemini", systemImage: "link")
            }
            
            Link(destination: URL(string: "https://thibaultgiraudon.github.io/striv-privacy/")!) {
                Label("Confidentialité App Store", systemImage: "apple.logo")
            }
        } header: {
            Text("Informations légales")
        }
    }
}
// MARK: - Actions
private extension SettingsView {
    
    func deleteUserData() {
        UserDefaults.standard.removeObject(forKey: "lastAIAnalysis")
        UserDefaults.standard.removeObject(forKey: "cachedWorkoutInsights")
    }
}
// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    section(
                        title: "Données collectées",
                        content: "Striv peut utiliser certaines données d’activité physique telles que la durée, la distance, l’allure moyenne, la fréquence cardiaque ou le dénivelé afin de fournir des analyses personnalisées."
                    )
                    
                    section(
                        title: "Utilisation de l’intelligence artificielle",
                        content: "Les analyses IA sont générées à l’aide du service Google Gemini. Certaines données de séance peuvent être transmises de manière sécurisée afin de produire des retours personnalisés."
                    )
                    
                    section(
                        title: "Protection des données",
                        content: "Aucune donnée directement identifiable telle que votre nom, votre adresse email ou votre identifiant utilisateur n’est transmise au modèle IA."
                    )
                }
                .padding()
            }
            .navigationTitle("Confidentialité")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func section(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
#Preview {
    SettingsView()
}
