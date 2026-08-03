//
//  AIViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation
import Combine

/// ViewModel responsible for generating AI analysis of a workout.
///
/// `AnalyseViewModel` communicates with `AIService` to produce
/// a textual analysis of a given workout.
///
/// If the analysis fails, the encountered error is exposed through
/// the `error` published property so the UI can react accordingly.
final class AnalyzeViewModel: ObservableObject {
    
    /// The latest error that occurred during an analysis request.
    ///
    /// When an error occurs, this property is updated so the UI
    /// can present an appropriate message to the user.
    @Published var error: AIError?
    
    /// Service responsible for communicating with the AI backend.
    private let aiService: AIService
    
    /// Creates a new `AnalyseViewModel`.
    ///
    /// - Parameter aiService: The service used to perform workout analysis.
    ///   A default instance is provided but can be injected for testing.
    init(aiService: AIService = .init()) {
        self.aiService = aiService
    }
    
    /// Generates an AI analysis for the given workout.
    ///
    /// This method sends the workout data to `AIService`
    /// which produces a textual analysis describing the run.
    ///
    /// If the analysis fails, the corresponding `AIError`
    /// is stored in the `error` property.
    ///
    /// - Parameter workout: The workout to analyze.
    /// - Returns: A textual analysis of the workout if the operation
    ///   succeeds, otherwise `nil`.
    @MainActor
    func analyze(_ workout: Workout, with goal: Goal) async throws -> String? {
        do {
            let prompt = makePrompt(for: workout, with: goal)
            return try await self.aiService.analyze(with: prompt)
        } catch let aiError as AIError {
            self.error = aiError
        } catch let consentError as AIConsentError {
            throw consentError
        } catch {
            self.error = .invalid
        }
        return nil
    }
    
    private func makePrompt(for workout: Workout, with goal: Goal) -> String {
        var prompts: [String] = []
        
        // MARK: - Objectif
        
        prompts.append("Objectif:")
        
        let goalDuration = Duration(goal.time * 60)
        let goalTitle = "\(goal.distance.title) en \(goalDuration.longLabel)"
        
        prompts.append(goalTitle)
        
        // MARK: - Summary

        prompts.append("Résumé:")
        
        prompts.append("Durée: \(workout.duration.label)")
        prompts.append("Allure moyenne: \(workout.pace.label)")
        
        if let distance = workout.distance {
            let speed = ((distance / Double(workout.duration.totalSeconds)) * 3.6).roundedText(to: 1)
            prompts.append("Vitesse moyenne: \(speed)km/h")
            prompts.append("Distance: \(distance) mètres")
        }
        if let hr = workout.hr { prompts.append("Fréquence cardiaque: \(hr) bpm") }
        if let kcal = workout.kcal { prompts.append("Calories: \(kcal) kcal") }
        if let elevation = workout.elevation { prompts.append("Dénivelé positif: \(elevation) mètres") }
        if let cadence = workout.cadence { prompts.append("Cadence: \(cadence) pas par minute") }
        if let power = workout.power { prompts.append("Puissance: \(power) watts") }
        
        // MARK: -
        
        prompts.append("""
        Données temporelles :
        Les valeurs suivantes représentent l'évolution de la séance dans le temps.
        Le temps est exprimé en secondes depuis le début de la séance.
        Les données ont été réduites pour faciliter l'analyse.
        """)
        
        if let paceSamples = workout.metricsSeries.first(where: { $0.type == .pace }) {
            prompts.append("ALLURE")
            
            for sample in paceSamples.samples.downSample(maxDisplayPoints: 50) {
                prompts.append("\(sample.time.roundedText(to: 0))s: \(Pace(pace: sample.value).label)")
            }
        }
        
        if let hrSamples = workout.metricsSeries.first(where: { $0.type == .heartRate }) {
            prompts.append("FREQUENCE CARDIAQUE")
            
            for sample in hrSamples.samples.downSample(maxDisplayPoints: 50) {
                prompts.append("\(sample.time.roundedText(to: 0))s: \(sample.value) bpm")
            }
        }
        
        if let elevationSamples = workout.metricsSeries.first(where: { $0.type == .elevation }) {
            prompts.append("DENIVELE")
            
            for sample in elevationSamples.samples.downSample(maxDisplayPoints: 50) {
                prompts.append("\(sample.time.roundedText(to: 0))s: \(sample.value) m")
            }
        }
        
        prompts.append("""
                Tu es un coach de course à pied.

                Analyse UNIQUEMENT cette séance de course, pas un plan d’entraînement global.
                Base-toi strictement sur les données fournies.
                Certaines données peuvent être absentes.
                Si une donnée n’est pas fournie, ignore-la complètement dans ton analyse.

                Objectif de l’analyse :
                - Aider le coureur à comprendre CE QUE cette séance a travaillé
                - Évaluer si l’objectif défini par le coureur est atteint ou non
                - Identifier 1 ou 2 points clés d’amélioration
                - Donner UN conseil clair pour la prochaine séance

                Règles d’évaluation de l’objectif :
                - Compare la performance réelle avec l’objectif utilisateur
                - Si l’objectif est atteint → considère-le comme réussi
                - Si la performance se rapproche de l’objectif → considère cela comme une progression positive

                IMPORTANT :
                - Tu ne dois PAS ajouter de champ spécifique pour l’objectif.
                - Tu dois intégrer le verdict directement dans le champ "summary".
                - Une séance peut être bénéfique même si l’objectif final n’est pas atteint
                - Valorise les signes de progression
                - Évite les jugements trop stricts ou décourageants
                - Si la séance est très différente de l’objectif (distance ou durée), considère qu’il s’agit d’une séance d’entraînement intermédiaire
                - Analyse alors la qualité de l’effort plutôt que l’atteinte directe de l’objectif

                Contraintes de réponse :
                - Ton clair, direct et bienveillant
                - Pas de généralités sur l’entraînement global
                - workedOn : 2 à 3 éléments
                - watchPoints : 2 à 3 éléments
                - Le résumé doit être compréhensible en une seule lecture rapide

                Réponds en suivant EXACTEMENT et UNIQUEMENT ce format:
                {
                    "summary": "",
                    "workedOn": ["", "", ...],
                    "watchPoints": ["", "", ...],
                    "nextAdvice": ""
                }

                Ne rajoute et n'enlève rien, la réponse doit être strictement conforme et sans Markdown.
                """)
        
        return prompts.joined(separator: "\n")
    }
}
