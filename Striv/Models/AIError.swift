//
//  AIError.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

enum AIError: Error, LocalizedError, Hashable {
    case internalAI
    case invalid
    case connection
    
    var title: String {
        switch self {
        case .internalAI:
            "Service error."
        case .invalid:
            "Internal error."
        case .connection:
            "No internet connection."
        }
    }
    
    var description: String {
        switch self {
        case .internalAI:
            "The service is currently unable to process your request."
        case .invalid:
            "We failed to process your request"
        case .connection:
            "Please check your connection and try again."
        }
    }
    
    var icon: String {
        switch self {
        case .internalAI:
            "wrench.and.screwdriver"
        case .invalid:
            "externaldrive.trianglebadge.exclamationmark"
        case .connection:
            "wifi.slash"
        }
    }
}
