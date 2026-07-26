//
//  GoalsViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import Foundation
import Combine
import SwiftData

class GoalsViewModel: BaseViewModel {
    @Published var goals: [Goal] = []
    
    private var context: ModelContext?
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    func saveGoal(_ goal: Goal) async {
        guard let context else {
            return
        }
        
        if let index = goals.firstIndex(where: { $0.distance == goal.distance }) {
            goals[index].time = goal.time
        } else {
            context.insert(goal)
        }
        
        do {
            try context.save()
        } catch {
            self.errorPresenter.error = .database(.saving)
        }
    }
    
    func getGoal(for distance: PresetDistance) -> Goal? {
        goals.first(where: { $0.distance == distance })
    }
    
    func getMainGoal(in goals: [Goal]) -> Goal? {
        goals.first(where: {$0.isMain == true})
    }
    
    func setMainGoal(for currentGoal: Goal) {
        guard let context else {
            return
        }
        
        guard let goalToUpdate = goals.first(where: {$0.distance == currentGoal.distance}) else { return }
        
        for goal in goals.filter({ $0.distance != currentGoal.distance }) {
            goal.isMain = false
        }
        
        goalToUpdate.isMain = currentGoal.isMain
        
        do {
            try context.save()
        } catch {
            self.errorPresenter.error = .database(.saving)
        }
    }
}
