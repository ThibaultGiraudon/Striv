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
    case database(DatabaseError)
    case validation(ValidationError)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .database(let databaseError):
            databaseError.errorDescription
        case .validation(let validationError):
            validationError.errorDescription
        case .unknown:
            "Une erreur inconnue est survenue."
        }
    }
    
    var id: UUID { UUID() }
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
            errorPresenter.error = .unknown
        }
    }
}
