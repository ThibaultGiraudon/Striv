//
//  WidgetDataViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/04/2026.
//

import Foundation
import Combine
import WidgetKit

class WidgetDataViewModel: ObservableObject {
    func saveWidgetData(_ data: WidgetData) {
        print("Saving data")
        let defaults = UserDefaults(suiteName: "group.striv")
        let encoded = try? JSONEncoder().encode(data)
        defaults?.set(encoded, forKey: "widgetData")
        
        WidgetCenter.shared.reloadAllTimelines()
    }
}
