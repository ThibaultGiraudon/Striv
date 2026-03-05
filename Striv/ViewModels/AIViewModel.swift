//
//  AIViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation
import Combine

final class AnalyseViewModel: ObservableObject {
    @Published var error: AIError?
    private let aiService: AIService
    
    init(aiService: AIService = .init()) {
        self.aiService = aiService
    }
    
    @MainActor
    func analyse(_ workout: Workout) async -> String? {
        do {
            return try await self.aiService.analyze(workout)
        } catch let aiError as AIError {
            self.error = aiError
        } catch {
            self.error = .invalid
        }
        return nil
    }
}
