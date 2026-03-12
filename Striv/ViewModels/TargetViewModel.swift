//
//  TargetViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 12/03/2026.
//

import Foundation
import Combine

class TargetViewModel: ObservableObject {
    var distanceTarget: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: distanceTargetKey)
        }
        
        get {
            UserDefaults.standard.value(forKey: distanceTargetKey) as? Int ?? 20
        }
    }
    
    var numberTarget: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: numberTargetKey)
        }
        
        get {
            UserDefaults.standard.value(forKey: numberTargetKey) as? Int ?? 3
        }
    }
    
    private var distanceTargetKey = "striv.target.distance"
    private var numberTargetKey = "striv.target.number"
    
    func setDistanceTarget(to distance: Int) {
        self.distanceTarget = distance
    }
    
    func setNumberTarget(to number: Int) {
        self.numberTarget = number
    }
}
