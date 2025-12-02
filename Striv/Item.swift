//
//  Item.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
