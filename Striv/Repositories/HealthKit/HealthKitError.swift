//
//  HealthKitError.swift
//  Striv
//
//  Created by Thibault Giraudon on 23/04/2026.
//

import Foundation

enum HealthKitError: LocalizedError, Equatable {
    case notAvailable
    case noDataOrNoPermission
    case invalidType
    case noData

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit n'est pas disponible sur cet appareil."
        case .noDataOrNoPermission:
            return "Aucune donnée n'a pu être récupérée. Vérifiez vos autorisations Santé ou l'existence d'activités."
        case .invalidType:
            return "Le type de données HealthKit demandé est invalide."
        case .noData:
            return "Aucune donnée HealthKit n'est disponible."
        }
    }
}
