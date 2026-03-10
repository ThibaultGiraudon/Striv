//
//  Analyze.swift
//  Striv
//
//  Created by Thibault Giraudon on 10/03/2026.
//

import SwiftUI

/// Represents the structured AI analysis of a workout.
///
/// `Analyze` contains multiple sections of textual insights generated
/// by the AI from a `Workout`. Each section can be displayed in the UI
/// to help the runner understand their performance and improvement points.
///
/// Example use cases:
/// - Displaying a summary of the session
/// - Highlighting what the workout trained
/// - Showing watch points or mistakes to avoid
/// - Giving actionable advice for the next session
struct Analyze: Equatable {
    
    /// Sections of the AI analysis.
    var sections: [AnalyzeSection]
    
    /// Represents a single section in the AI analysis.
    ///
    /// Each section has a `title` and an array of `items`.
    /// `id` is auto-generated to conform to `Identifiable` for SwiftUI lists.
    struct AnalyzeSection: Identifiable, Hashable {
        
        /// Unique identifier of the section.
        let id = UUID()
        
        /// Title of the section (e.g., "Résumé", "Ce que cette séance a travaillé").
        var title: String
        
        /// Textual items associated with the section.
        ///
        /// Typically, the AI will generate 1–4 bullet points or a short paragraph per section.
        var items: [String]
    }
}
