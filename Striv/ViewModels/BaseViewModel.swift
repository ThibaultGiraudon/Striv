//
//  BaseViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 22/04/2026.
//

import Foundation
import Combine

enum DatabaseError: LocalizedError, Equatable {
    case saving
    case fetching
    
    var errorDescription: String? {
        switch self {
        case .saving:
            "Une erreur est survenue en enregistrant les données."
        case .fetching:
            "Une erreur est survenue en récupérant les données."
        }
    }
}

enum ValidationError: LocalizedError, Equatable {
    case type
    case empty
    
    var errorDescription: String? {
        switch self {
        case .type:
            "La valeur renseignée ne correspond pas au type demandé."
        case .empty:
            "Veuillez remplir tout les champs obligatoires."
        }
    }
}

enum AppError: LocalizedError, Equatable, Identifiable {
    case database(DatabaseError, id: UUID = UUID())
    case validation(ValidationError, id: UUID = UUID())
    case healthKit(HealthKitError, id: UUID = UUID())
    case unknown(id: UUID = UUID())

    var errorDescription: String? {
        switch self {
        case .database(let databaseError, _):
            return databaseError.errorDescription
        case .validation(let validationError, _):
            return validationError.errorDescription
        case .healthKit(let healthKitError, _):
            return healthKitError.errorDescription
        case .unknown:
            return "Une erreur inconnue est survenue."
        }
    }

    var id: UUID {
        switch self {
        case .database(_, let id),
             .validation(_, let id),
             .healthKit(_, let id),
             .unknown(let id):
            return id
        }
    }
}

@MainActor
final class ErrorPresenter: ObservableObject {
    @Published var error: AppError?
}

@MainActor
class BaseViewModel: ObservableObject {
    let errorPresenter: ErrorPresenter
    
    init(errorPresenter: ErrorPresenter) {
        self.errorPresenter = errorPresenter
    }

    func handleError(_ error: Error) {
        switch error {
        case let appError as AppError:
            errorPresenter.error = appError
            
        case let dbError as DatabaseError:
            errorPresenter.error = .database(dbError)
            
        case let validationError as ValidationError:
            errorPresenter.error = .validation(validationError)
            
        default:
            errorPresenter.error = .unknown()
        }
    }
}
