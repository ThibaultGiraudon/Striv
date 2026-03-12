//
//  StatDisplayable.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

protocol StatDisplayable {
    var statText: String { get }
}

extension String: StatDisplayable {
    var statText: String {
        self
    }
}

extension Double: StatDisplayable {
    var statText: String {
        String(format: "%.0f", self)
    }
    
    func roundedText(to numbers: Int) -> String {
        String(format: "%.\(numbers)f", self)
    }
}

extension Int: StatDisplayable {
    var statText: String {
        String(describing: self)
    }
}
