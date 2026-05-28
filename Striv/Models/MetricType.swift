//
//  MetricType.swift
//  Striv
//
//  Created by Thibault Giraudon on 06/05/2026.
//

import Foundation

enum MetricType: String, CaseIterable, Identifiable {
    case pace
    case heartRate
    case cadence
    case power
    case time
    case elevation
    case calories
    
    var id: String { rawValue }
}

extension MetricType {
    
    var title: String {
        switch self {
        case .pace: return "Allure"
        case .heartRate: return "Fréquence cardiaque"
        case .cadence: return "Cadence"
        case .power: return "Puissance"
        case .time: return "Temps"
        case .elevation: return "Dénivelé"
        case .calories: return "Calories"
        }
    }
    
    var unit: String {
        switch self {
        case .pace: return "par kilomètre"
        case .heartRate: return "battement par minutes"
        case .cadence: return "pas par minute"
        case .power: return "watt"
        case .time: return ""
        case .elevation: return "mètre"
        case .calories: return "kilocalorie"
        }
    }
    
    var icon: String {
        switch self {
        case .pace: return "figure.run"
        case .heartRate: return "heart.fill"
        case .cadence: return "shoeprints.fill"
        case .power: return "bolt.fill"
        case .time: return "clock.fill"
        case .elevation: return "mountain.2.fill"
        case .calories: return "flame.fill"
        }
    }
    
    func valuePlusUnit(_ value: String) -> String {
        "\(value) \(self.unit)"
    }
}

extension MetricType {
    
    var definition: String {
        switch self {
        case .pace:
            return "Temps nécessaire pour parcourir un kilomètre."
        case .heartRate:
            return "Nombre de battements de ton cœur par minute."
        case .cadence:
            return "Nombre de pas que tu fais par minute."
        case .power:
            return "Effort que tu produis en courant, exprimé en watts."
        case .time:
            return "Durée totale de ta course."
        case .elevation:
            return "Différence totale de hauteur parcourue pendant ta course."
        case .calories:
            return "Énergie dépensée pendant ton activité."
        }
    }
    
    var whyItMatters: String {
        switch self {
        case .pace:
            return "Permet de suivre ta vitesse et ta progression."
        case .heartRate:
            return "Indique l’intensité réelle de ton effort."
        case .cadence:
            return "Améliore ton efficacité et réduit les blessures."
        case .power:
            return "Aide à gérer ton effort indépendamment du terrain."
        case .time:
            return "Permet de mesurer ton volume d’entraînement."
        case .elevation:
            return "Permet de mesurer la difficulté de ton parcours."
        case .calories:
            return "Donne une estimation de ton effort énergétique."
        }
    }
    
    var tip: String {
        switch self {
        case .pace:
            return "Essaie de maintenir une allure régulière."
        case .heartRate:
            return "La majorité de tes runs devraient être en zone facile."
        case .cadence:
            return "Augmente légèrement ta cadence pour progresser."
        case .power:
            return "Garde une puissance stable plutôt qu’une allure fixe."
        case .time:
            return "Augmente progressivement la durée de tes sorties."
        case .elevation:
            return "Adapte ton effort en montée, ne cherche pas à garder la même allure."
        case .calories:
            return "Utilise cette donnée comme indicateur global, pas comme valeur exacte."
        }
    }
}

extension MetricType {
    
    var typicalValues: [(String, String)] {
        switch self {
            
        case .cadence:
            return [
                ("Débutant", "150–165 spm"),
                ("Intermédiaire", "165–175 spm"),
                ("Avancé", "175–185+ spm")
            ]
            
        case .heartRate:
            return [
                ("Facile", "60–70% FC max"),
                ("Endurance", "70–80% FC max"),
                ("Intense", "80–90% FC max")
            ]
            
        case .power:
            return [
                ("Dépendance", "Liée au poids")
            ]
            
        case .pace:
            return [
                ("Variabilité", "Selon le niveau"),
                ("Suivi", "À comparer dans le temps")
            ]
            
        case .time:
            return [
                ("Variable", "Dépend de ton objectif")
            ]
            
        case .elevation:
            return [
                ("Variable", "Dépend de la distance")
            ]
            
        case .calories:
            return [
                ("Facteur", "Dépend du poids"),
                ("Intensité", "Varie selon l’effort"),
                ("Précision", "Valeur approximative")
            ]
        }
    }
}
