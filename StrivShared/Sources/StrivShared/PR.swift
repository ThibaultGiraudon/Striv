//
//  PR.swift
//  StrivShared
//
//  Created by Thibault Giraudon on 12/05/2026.
//

import Foundation

public struct PR: Codable, Hashable {
    public let title: String
    public let value: String
    public let distance: Double
    
    public init(title: String, value: String, distance: Double) {
        self.title = title
        self.value = value
        self.distance = distance
    }
}
