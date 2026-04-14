//
//  AIViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//

import Foundation
import Combine

/// ViewModel responsible for generating AI analysis of a workout.
///
/// `AnalyseViewModel` communicates with `AIService` to produce
/// a textual analysis of a given workout.
///
/// If the analysis fails, the encountered error is exposed through
/// the `error` published property so the UI can react accordingly.
final class AnalyzeViewModel: ObservableObject {
    
    /// The latest error that occurred during an analysis request.
    ///
    /// When an error occurs, this property is updated so the UI
    /// can present an appropriate message to the user.
    @Published var error: AIError?
    
    /// Service responsible for communicating with the AI backend.
    private let aiService: AIService
    
    /// Creates a new `AnalyseViewModel`.
    ///
    /// - Parameter aiService: The service used to perform workout analysis.
    ///   A default instance is provided but can be injected for testing.
    init(aiService: AIService = .init()) {
        self.aiService = aiService
    }
    
    /// Generates an AI analysis for the given workout.
    ///
    /// This method sends the workout data to `AIService`
    /// which produces a textual analysis describing the run.
    ///
    /// If the analysis fails, the corresponding `AIError`
    /// is stored in the `error` property.
    ///
    /// - Parameter workout: The workout to analyze.
    /// - Returns: A textual analysis of the workout if the operation
    ///   succeeds, otherwise `nil`.
    @MainActor
    func analyze(_ workout: Workout, with profile: RunnerProfile) async -> String? {
        do {
            return try await self.aiService.analyze(workout, with: profile)
        } catch let aiError as AIError {
            self.error = aiError
        } catch {
            self.error = .invalid
        }
        return nil
    }
}
