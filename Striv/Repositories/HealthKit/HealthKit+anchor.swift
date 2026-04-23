//
//  HealthKit+anchor.swift
//  Striv
//
//  Created by Thibault Giraudon on 23/04/2026.
//

import Foundation
import HealthKit

extension HealthKitHelper {
    
    func getAnchor() -> HKQueryAnchor? {
        guard
            let data = UserDefaults.standard.data(forKey: anchorKey),
            let anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
        else {
            return nil
        }
        return anchor
    }
    
    nonisolated
    func saveAnchor(_ anchor: HKQueryAnchor) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
        UserDefaults.standard.set(data, forKey: anchorKey)
    }
}
