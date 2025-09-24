import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
       private weak var viewController: MovieQuizViewController?
       
       init(viewController: MovieQuizViewController) {
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
           guard let question = question else {
               return
           }
           
           currentQuestion = question
           let viewData = makeStepViewData(from: question)
           DispatchQueue.main.async { [weak self] in
               self?.viewController?.show(quiz: viewData)
           }
       }
    
    var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    var correctAnswers: Int = 0
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer { correctAnswers += 1 }
    }
    private func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            let givenAnswer = isYes
            
            self.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
    
    func showNextQuestionOrResults() {
        
        
        if self.isLastQuestion() {
            
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            let bestGame = statisticService.bestGame
            let result: QuizResultViewData = QuizResultViewData(
                title: "Этот раунд окончен!",
                text: """
                Ваш результат: \(correctAnswers)/\(self.questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(self.questionsAmount) (\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """,
                buttonText: "Сыграть ещё раз")

            viewController?.showResult(quiz: result)
        }else{
            questionFactory?.requestNextQuestion()
            viewController?.showLoadingIndicator()
        }
    }
    
    func makeResultsMessage() -> String {
           statisticService.store(correct: correctAnswers, total: questionsAmount)
           
           let bestGame = statisticService.bestGame
           
           let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
           let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
           let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
           + " (\(bestGame.date.dateTimeString))"
           let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
           
           let resultMessage = [
               currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
           ].joined(separator: "\n")
           
           return resultMessage
       }
    func showAnswerResult(isCorrect: Bool) {
            didAnswer(isCorrectAnswer: isCorrect)
            
            viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.showNextQuestionOrResults()
            }
        }
}
