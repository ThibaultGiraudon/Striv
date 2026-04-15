//
//  RunnerProfileViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 10/04/2026.
//

import Foundation
import Combine
import SwiftData

class RunnerProfileViewModel: ObservableObject {
    private var context: ModelContext?
    
    func setContext(context: ModelContext) {
        self.context = context
    }
    
    func profileExist() -> RunnerProfile? {
        guard let context else { return nil }
        
        let descriptor = FetchDescriptor<RunnerProfile>()
        do {
            return try context.fetch(descriptor).first
        } catch {
            return nil
        }
    }
    
    func createProfileIfNeeded() {
        guard let context, profileExist() == nil else {
            return
        }

        let profile = RunnerProfile(goal: .init(type: .distance, distance: .preset(.tenK)))
        
        do {
            context.insert(profile)
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func save(_ goal: Goal, for profile: RunnerProfile?) -> Bool {
        guard let context, let profile else {
            return false
        }
        
        do {
            profile.goal = goal
            
            try context.save()
        } catch {
            print(error.localizedDescription)
            return false
        }
        return true
    }
    
    func updatePRs(_ prs: [PRResult]) -> Bool {
        guard let context, let profile = profileExist() else {
            return false
        }
        
        var currentsPRs = profile.prs
        
        do {
            for pr in prs {
                if let current = currentsPRs[pr.prDistance] {
                    if pr.time < current.time {
                        currentsPRs[pr.prDistance] = pr
                    }
                } else {
                    currentsPRs[pr.prDistance] = pr
                }
            }
            profile.encodePRs(with: currentsPRs)
            try context.save()
        } catch {
            print(error.localizedDescription)
            return false
        }
        return true
    }
}
