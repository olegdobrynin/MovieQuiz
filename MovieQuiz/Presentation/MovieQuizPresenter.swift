import Foundation
import UIKit

final class MovieQuizPresenter {
    private var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func makeStepViewData(from model: QuizQuestion) -> QuizStepViewData {
        QuizStepViewData(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    // MARK: - Actions
    
    func yesAnswerTapped() {
        didAnswer(isYes: true)
    }

    func noAnswerTapped() {
        didAnswer(isYes: false)
    }

    private func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = isYes
            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
}
