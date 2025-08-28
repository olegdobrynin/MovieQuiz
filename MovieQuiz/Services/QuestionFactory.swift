//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by OLEGG on 21.08.2025.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let questions: [QuizQuestion] = QuizQuestion.mocks()
    weak var delegate: QuestionFactoryDelegate?
    
    func requestNextQuestion() { // 1
        // 2
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        delegate?.didReceiveNextQuestion(question: questions[safe: index])
    }
}
