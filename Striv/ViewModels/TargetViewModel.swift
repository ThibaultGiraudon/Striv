//
//  TargetViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 12/03/2026.
//

import Foundation
import Combine

/// ViewModel responsible for managing the user’s running targets.
///
/// `TargetViewModel` stores and retrieves user-defined goals such as
/// the weekly distance target and the number of runs per week.
/// These values are persisted using `UserDefaults` so they remain
/// available across app launches.
///
/// Example use cases:
/// - Allow the user to define a weekly distance goal
/// - Track how many runs per week the user wants to complete
/// - Provide targets for dashboard comparisons
class TargetViewModel: ObservableObject {
    
    /// Weekly distance target set by the user.
    ///
    /// Value is persisted in `UserDefaults`.
    /// Default value: **20 km**.
    var distanceTarget: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: distanceTargetKey)
        }
        get {
            UserDefaults.standard.value(forKey: distanceTargetKey) as? Int ?? 20
        }
    }
    
    /// Weekly number of runs target set by the user.
    ///
    /// Value is persisted in `UserDefaults`.
    /// Default value: **3 runs per week**.
    var numberTarget: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: numberTargetKey)
        }
        get {
            UserDefaults.standard.value(forKey: numberTargetKey) as? Int ?? 3
        }
    }
    
    // MARK: - UserDefaults Keys
    
    /// UserDefaults key used to store the distance target.
    private var distanceTargetKey = "striv.target.distance"
    
    /// UserDefaults key used to store the number of runs target.
    private var numberTargetKey = "striv.target.number"
    
    // MARK: - Methods
    
    /// Updates the weekly distance target.
    ///
    /// - Parameter distance: Target distance in kilometers.
    func setDistanceTarget(to distance: Int) {
        self.distanceTarget = distance
    }
    
    /// Updates the weekly number of runs target.
    ///
    /// - Parameter number: Target number of runs per week.
    func setNumberTarget(to number: Int) {
        self.numberTarget = number
    }
}
