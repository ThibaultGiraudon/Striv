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

    private var model: GenerativeModel { ai.generativeModel(modelName: "gemini-2.5-flash-lite") }
    
    func askGemini(with input: String) async throws -> String {
        let response = try await model.generateContent(input)
                
        guard let text = response.text else {
            throw AIDecodeError.unknown
        }
        
        return text
    }
}

enum AIDecodeError: Swift.Error, LocalizedError, Hashable {
    case wrongType
    case missingKey
    case unknown
}
