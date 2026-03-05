//
//  AIService.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation
import FirebaseAI

final class AIService {
    private let aiRepository: AIRepository
    private let networkMonitor: NetworkMonitor
    
    init(aiRepository: AIRepository = .init(), networkMonitor: NetworkMonitor = .init()) {
        self.aiRepository = aiRepository
        self.networkMonitor = networkMonitor
    }
    
    func analyze(_ workout: Workout) async throws -> Analyse {
        guard networkMonitor.execute() else {
            throw AIError.connection
        }

        do {
            return try await aiRepository.askGemini(with: workout.analysePrompt)
        } catch is GenerateContentError {
            throw AIError.internalAI
        } catch {
            throw AIError.invalid
        }
    }
}
