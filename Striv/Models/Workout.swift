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

struct Analyse: Equatable {
    var sections: [AnalyseSection]
    
    struct AnalyseSection: Identifiable, Hashable {
        let id = UUID()
        var title: String
        var items: [String]
    }
}

@Model
final class Coordinate {
    var latitude: Double
    var longitude: Double
    var timestamp: Date

    init(latitude: Double, longitude: Double, timestamp: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
}

@Model
class Workout: Identifiable, Equatable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var distance: Double?
    var duration: Duration
    var hr: Double?
    var kcal: Double?
    var elevation: Double?
    var cadence: Double?
    var power: Double?
    @Transient var pace: Pace {
        Pace(pace:  Double(duration.totalSeconds / 60) / ((distance ?? 1) / 1000))
    }
    @Relationship var coordinates: [Coordinate]
    @Transient var coordinates2d: [CLLocationCoordinate2D] {
        coordinates
            .sorted { $0.timestamp > $1.timestamp }
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }
    var altitudes: [Double] = []
    
    @Transient var analysePrompt: String {
        var prompts: [String] = []

        prompts.append("""
        Tu es un coach de course à pied spécialisé dans la préparation marathon.

        Analyse UNIQUEMENT cette séance de course, pas un plan d’entraînement global.
        Base-toi strictement sur les données fournies.
        N’invente pas d’informations manquantes : indique-les brièvement si nécessaire.

        Objectif de l’analyse :
        - Aider le coureur à comprendre CE QUE cette séance a travaillé
        - Identifier 1 ou 2 points clés d’amélioration
        - Donner UN conseil clair pour la prochaine séance

        Contraintes de réponse :
        - Maximum 180 mots
        - Ton clair, direct et bienveillant
        - Pas de généralités sur “comment préparer un marathon”
        - Pas plus de 4 bullet points par section

        Réponds en suivant EXACTEMENT et UNIQUEMENT ce format:
        {
            "summary": "",
            "workedOn": ["", "", ...],
            "watchPoints": ["", "", ...],
            "nextAdvice": ""
        }
        
        Ne rajoute et n'enlève rien, la réponse doit contenir uniquement ce modèle et ne doit PAS être formatté en Markdown ou en JSON.
        """)

        prompts.append("Objectif: Marathon")
        prompts.append("Date: \(date)")
        prompts.append("Durée: \(duration.totalSeconds) secondes")

        if let distance {
            prompts.append("Distance: \(distance) mètres")
        }
        if let hr {
            prompts.append("Fréquence cardiaque: \(hr) bpm")
        }
        if let kcal {
            prompts.append("Calories: \(kcal) kcal")
        }
        if let elevation {
            prompts.append("Dénivelé positif: \(elevation) mètres")
        }
        if let cadence {
            prompts.append("Cadence: \(cadence) pas par minute")
        }
        if let power {
            prompts.append("Puissance: \(power) watts")
        }

        return prompts.joined(separator: "\n")
    }
    
    @Transient var analyse: Analyse? {
        
        guard let data = analyseRaw?.data(using: .utf8) else {
            return nil
        }
        
        if let jsonSerialize = try? JSONSerialization.jsonObject(with: data) as? Dictionary<String, Any> {
            guard let summary = jsonSerialize["summary"] as? String,
                  let workedOn = jsonSerialize["workedOn"] as? [String],
                  let watchOn = jsonSerialize["watchPoints"] as? [String],
                  let nextAdvice = jsonSerialize["nextAdvice"] as? String else {
                return nil
            }
            let analyse = Analyse(sections: [
                .init(title: "Résumé", items: [summary]),
                .init(title: "Ce que cette séance a travaillé", items: workedOn),
                .init(title: "Points de vigilance", items: watchOn),
                .init(title: "Conseil clé pour la prochaine séance", items: [nextAdvice])
            ])
            return analyse
        }
        
        return nil
    }
    var analyseRaw: String?
    
    init(id: UUID, date: Date, distance: Double? = nil, duration: Duration, hr: Double? = nil, kcal: Double? = nil, elevation: Double? = nil, cadence: Double? = nil, power: Double? = nil, coordinates: [Coordinate] = [], altitudes: [Double] = [], analyseRaw: String? = nil) {
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
        self.analyseRaw = analyseRaw
    }
    
    struct Pace: Equatable {
        var minutes: Int
        var seconds: Int
        
        var label: String {
            String(format: "%02d\'%02d\"/km", minutes, seconds)
        }
        
        init(pace: Double) {
            self.minutes = Int(pace / 1)
            self.seconds = Int(pace.truncatingRemainder(dividingBy: 1) * 60)
        }
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id
    }
}

