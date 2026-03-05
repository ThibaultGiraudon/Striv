//
//  Array+Downsample.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

extension Array<Double> {
    func downSample(maxDisplayPoints: Int = 300) -> [Double] {
        guard self.count > maxDisplayPoints else {
            return self
        }

        let windowSize = Int(ceil(
            Double(self.count) / Double(maxDisplayPoints)
        ))

        return stride(from: 0, to: self.count, by: windowSize).map { start in
            let end = Swift.min(start + windowSize, self.count)
            let window = self[start..<end]
            return window.reduce(0, +) / Double(window.count)
        }
    }
}
