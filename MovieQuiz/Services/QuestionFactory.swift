//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by OLEGG on 21.08.2025.
//

import Foundation

class QuestionFactory {
    private let questions: [QuizQuestion] = QuizQuestion.mocks()
    
    func requestNextQuestion() -> QuizQuestion? { // 1
        // 2
        guard let index = (0..<questions.count).randomElement() else {
            return nil
        }

        return questions[safe: index] // 3
    }
}
