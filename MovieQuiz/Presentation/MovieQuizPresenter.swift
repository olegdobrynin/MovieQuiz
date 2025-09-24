import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - Properties
    private let statisticService: StatisticServiceProtocol
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private(set) var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers: Int = 0
    let questionsAmount: Int = 10
    
    // MARK: - Init
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewData = makeStepViewData(from: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewData)
        }
    }
    
    // MARK: - Actions
    
    func yesAnswerTapped() {
        didAnswer(isYes: true)
    }
    
    func noAnswerTapped() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = isYes == currentQuestion.correctAnswer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            let message = makeResultsMessage()
            let result = QuizResultViewData(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть ещё раз"
            )
            viewController?.showResult(quiz: result)
        } else {
            questionFactory?.requestNextQuestion()
            viewController?.showLoadingIndicator()
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount
    }
    
    // MARK: - Helpers
    
   func makeStepViewData(from model: QuizQuestion) -> QuizStepViewData {
        return QuizStepViewData(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine,
            totalPlaysCountLine,
            bestGameInfoLine,
            averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
}
