//
//  Workout.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation
import CoreLocation

typealias Workouts = [Workout]

struct Workout: Identifiable {
    let id = UUID()
    var date: Date
    var distance: Double?
    var duration: Duration
    var hr: Double?
    var kcal: Double?
    var elevation: Double?
    var cadence: Double?
    var power: Double?
    var pace: Pace {
        Pace(pace:  Double(duration.totalSeconds / 60) / ((distance ?? 1) / 1000))
    }
    var coordinates: [CLLocationCoordinate2D]
    
    var analysePrompt: String {
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

        Structure OBLIGATOIRE :

        ### Résumé
        (2 phrases maximum)

        ### Ce que cette séance a travaillé
        (2 à 4 points courts)

        ### Points de vigilance
        (1 à 2 points maximum)

        ### Conseil clé pour la prochaine séance
        (1 phrase concrète et actionnable)

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

    
    struct Duration {
        var hours: Int
        var minutes: Int
        var seconds: Int
        var totalSeconds: Int
        
        init(_ time: Int) {
            self.hours = time / 3600
            self.minutes = (time % 3600) / 60
            self.seconds = time % 60
            self.totalSeconds = time
        }
    }
    
    struct Pace {
        var minutes: Int
        var seconds: Int
        
        init(pace: Double) {
            self.minutes = Int(pace / 1)
            self.seconds = Int(pace.truncatingRemainder(dividingBy: 1) * 60)
        }
    }
}
