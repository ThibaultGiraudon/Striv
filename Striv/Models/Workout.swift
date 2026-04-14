//
//  Workout.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation
import CoreLocation
import SwiftData

typealias Workouts = [Workout]

/// Represents a running workout.
///
/// `Workout` stores all the essential metrics of a running session,
/// including distance, duration, heart rate, cadence, elevation, power,
/// GPS coordinates, and optional AI-generated analysis.
///
/// This model is designed to work with SwiftData (`@Model`) and
/// can be persisted locally. It also provides computed properties
/// for pace, 2D coordinates, and AI analysis prompts.
@Model
class Workout: Identifiable, Equatable {
    
    // MARK: - Properties
    
    /// Unique identifier of the workout.
    @Attribute(.unique) var id: UUID
    
    /// Date of the workout session.
    var date: Date
    
    /// Distance covered in meters.
    var distance: Double?
    
    /// Duration of the workout.
    var duration: Duration
    
    /// Average heart rate in beats per minute.
    var hr: Double?
    
    /// Calories burned.
    var kcal: Double?
    
    /// Total elevation gain in meters.
    var elevation: Double?
    
    /// Step cadence in steps per minute.
    var cadence: Double?
    
    /// Power output in watts (if available).
    var power: Double?
    
    /// GPS coordinates associated with the workout.
    @Relationship var coordinates: [Coordinate]
    
    /// Altitudes recorded along the route.
    var altitudes: [Double] = []
    
    /// Raw JSON string returned by the AI analysis.
    var analyzeRaw: String?
    
    // MARK: - Computed Properties
    
    /// Computes pace of the workout (minutes/km).
    @Transient var pace: Pace {
        Pace(pace: Double(duration.totalSeconds / 60) / ((distance ?? 1) / 1000))
    }
    
    /// Returns coordinates as `CLLocationCoordinate2D`, sorted by timestamp descending.
    @Transient var coordinates2d: [CLLocationCoordinate2D] {
        coordinates
            .sorted { $0.timestamp > $1.timestamp }
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }
    
    /// Generates the AI prompt to analyze this workout.
    func analyzePrompt(with profile: RunnerProfile) -> String {
        var prompts: [String] = []
        
        // TODO: ajouter formulaire pour définir un objecif (temps/allure ou distance) avec enum pour différencié
        // TODO: mettre temps/allure max pour être réaliste ?
        
        prompts.append("""
        Tu es un coach de course à pied.

        Analyse UNIQUEMENT cette séance de course, pas un plan d’entraînement global.
        Base-toi strictement sur les données fournies.
        N’invente pas d’informations manquantes : indique-les brièvement si nécessaire.

        Objectif de l’analyse :
        - Aider le coureur à comprendre CE QUE cette séance a travaillé
        - Évaluer si l’objectif défini par le coureur est atteint ou non
        - Identifier 1 ou 2 points clés d’amélioration
        - Donner UN conseil clair pour la prochaine séance

        Règles d’évaluation de l’objectif :
        - Compare la performance réelle avec l’objectif utilisateur
        - Si l’objectif est atteint → considère-le comme réussi
        - Si l’objectif est incohérent avec la performance ou les données → considère-le comme IRRÉALISTE / NON ATTEIGNABLE à l'instant T

        IMPORTANT :
        Tu ne dois PAS ajouter de champ spécifique pour l’objectif.
        Tu dois intégrer le verdict directement dans le champ "summary".

        Contraintes de réponse :
        - Maximum 180 mots
        - Ton clair, direct et bienveillant
        - Pas de généralités sur l’entraînement global
        - Pas plus de 4 bullet points par section

        Réponds en suivant EXACTEMENT et UNIQUEMENT ce format:
        {
            "summary": "",
            "workedOn": ["", "", ...],
            "watchPoints": ["", "", ...],
            "nextAdvice": ""
        }

        Ne rajoute et n'enlève rien, la réponse doit être strictement conforme et sans Markdown.
        """)
        
        prompts.append(profile.goalDescription())
        prompts.append("Date: \(date)")
        prompts.append("Durée: \(duration.totalSeconds) secondes")
        
        if let distance { prompts.append("Distance: \(distance) mètres") }
        if let hr { prompts.append("Fréquence cardiaque: \(hr) bpm") }
        if let kcal { prompts.append("Calories: \(kcal) kcal") }
        if let elevation { prompts.append("Dénivelé positif: \(elevation) mètres") }
        if let cadence { prompts.append("Cadence: \(cadence) pas par minute") }
        if let power { prompts.append("Puissance: \(power) watts") }
        
        return prompts.joined(separator: "\n")
    }
    
    /// Returns an `Analyze` object parsed from `analyzeRaw`.
    ///
    /// Contains:
    /// - Résumé
    /// - Ce que cette séance a travaillé
    /// - Points de vigilance
    /// - Conseil clé pour la prochaine séance
    @Transient var analyze: Analyze? {
        guard let data = analyzeRaw?.data(using: .utf8) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let summary = json["summary"] as? String,
              let workedOn = json["workedOn"] as? [String],
              let watchOn = json["watchPoints"] as? [String],
              let nextAdvice = json["nextAdvice"] as? String else { return nil }
        
        return Analyze(sections: [
            .init(title: "Résumé", items: [summary]),
            .init(title: "Ce que cette séance a travaillé", items: workedOn),
            .init(title: "Points de vigilance", items: watchOn),
            .init(title: "Conseil clé pour la prochaine séance", items: [nextAdvice])
        ])
    }
    
    // MARK: - Initializer
    
    /// Creates a new `Workout`.
    init(
        id: UUID,
        date: Date,
        distance: Double? = nil,
        duration: Duration,
        hr: Double? = nil,
        kcal: Double? = nil,
        elevation: Double? = nil,
        cadence: Double? = nil,
        power: Double? = nil,
        coordinates: [Coordinate] = [],
        altitudes: [Double] = [],
        analyzeRaw: String? = nil
    ) {
        self.id = id
        self.date = date
        self.distance = distance
        self.duration = duration
        self.hr = hr
        self.kcal = kcal
        self.elevation = elevation
        self.cadence = cadence
        self.power = power
        self.coordinates = coordinates
        self.altitudes = altitudes
        self.analyzeRaw = analyzeRaw
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Workout, rhs: Workout) -> Bool { lhs.id == rhs.id }
    
    // MARK: - Nested Types
    
    /// Represents pace in minutes and seconds per kilometer.
    struct Pace: Equatable {
        var minutes: Int
        var seconds: Int
        
        var label: String { String(format: "%02d'%02d\"/km", minutes, seconds) }
        
        init(pace: Double) {
            self.minutes = Int(pace / 1)
            self.seconds = Int(pace.truncatingRemainder(dividingBy: 1) * 60)
        }
    }
}

