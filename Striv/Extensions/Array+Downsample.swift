//
//  Array+Downsample.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation

extension Array<Double> {
    func downSample(maxDisplayPoints: Int = 300) -> [Double] {
        guard maxDisplayPoints > 0 else {
            return []
        }
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

extension Array<MetricSampleEntity> {
    func downSample(maxDisplayPoints: Int = 100) -> [MetricSampleEntity] {

        guard self.count > maxDisplayPoints else {
            return self
        }

        let windowSize = Int(
            ceil(Double(self.count) / Double(maxDisplayPoints))
        )

        return stride(
            from: 0,
            to: self.count,
            by: windowSize
        ).compactMap { start in

            let end = Swift.min(
                start + windowSize,
                self.count
            )

            let window = self[start..<end]

            guard !window.isEmpty else {
                return nil
            }

            return MetricSampleEntity(
                time: window.map(\.time).average,
                value: window.map(\.value).average,
                normalizedValue: window.map(\.normalizedValue).average
            )
        }
    }
}
