//
//  HealthKitError.swift
//  Striv
//
//  Created by Thibault Giraudon on 23/04/2026.
//

import Foundation

enum HealthKitError: Error {
    case notAvailable
    case notAuthorized
    case invalidType
    case noData
}
