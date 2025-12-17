//
//  AIRepository.swift
//  Striv
//
//  Created by Thibault Giraudon on 17/12/2025.
//

import Foundation
import FirebaseAI

class AIRepository {
    private let ai = FirebaseAI.firebaseAI(backend: .googleAI())

    // Create a `GenerativeModel` instance with a model that supports your use case
    private var model: GenerativeModel { ai.generativeModel(modelName: "gemini-2.5-flash-lite") }
    
    func askGemini(with input: String) async throws -> Analyse {
        let response = try await model.generateContent(input)
                
        guard let data = response.text?.data(using: .utf8) else {
            throw AIError.unknown
        }
                    
        if let jsonSerialize = try JSONSerialization.jsonObject(with: data) as? Dictionary<String, Any> {
            guard let summary = jsonSerialize["summary"] as? String,
                  let workedOn = jsonSerialize["workedOn"] as? [String],
                  let watchOn = jsonSerialize["watchPoints"] as? [String],
                  let nextAdvice = jsonSerialize["nextAdvice"] as? String else {
                throw AIError.missingKey
            }
            let analyse = Analyse(sections: [
                .init(title: "Résumé", items: [summary]),
                .init(title: "Ce que cette séance a travaillé", items: workedOn),
                .init(title: "Points de vigilance", items: watchOn),
                .init(title: "Conseil clé pour la prochaine séance", items: [nextAdvice])
            ])
            return analyse
        }
        throw AIError.wrongType
    }
}

enum AIError: Swift.Error, LocalizedError, Hashable {
    case wrongType
    case missingKey
    case unknown
}
