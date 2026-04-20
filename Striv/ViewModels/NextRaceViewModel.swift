//
//  NextRaceViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 20/04/2026.
//

import Foundation
import Combine

class NextRaceViewModel: ObservableObject {
    @Published var date: Date
    @Published var title: String

    private let nextRaceDateKey = "striv.nextRace.date"
    private let nextRaceTitleKey = "striv.nextRace.title"

    init() {
        self.date = UserDefaults.standard.value(forKey: nextRaceDateKey) as? Date ?? .now
        self.title = UserDefaults.standard.string(forKey: nextRaceTitleKey) ?? ""
    }
    
    func setDate(_ date: Date) {
        self.date = date
        UserDefaults.standard.set(date, forKey: nextRaceDateKey)
    }

    func setTitle(_ title: String) {
        self.title = title
        UserDefaults.standard.set(title, forKey: nextRaceTitleKey)
    }
    
    func formatTime(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: .now, to: date)
        
        let months = components.month ?? 0
        let days = components.day ?? 0
        
        if months > 0 {
            return "\(months) mois \(days) jours"
        } else {
            return "\(days) jours"
        }
    }
}
