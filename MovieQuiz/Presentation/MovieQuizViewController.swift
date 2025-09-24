import UIKit
import Foundation
// MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - Outlets
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var questionTextLabel: UILabel!
    @IBOutlet private weak var questionCounterLabel: UILabel!
    @IBOutlet private weak var yesAnswerButton: UIButton!
    @IBOutlet private weak var noAnswerButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties
    

    private var correctAnswers = 0
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private lazy var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yesAnswerButton.layer.cornerRadius = 15
        noAnswerButton.layer.cornerRadius = 15
        yesAnswerButton.layer.masksToBounds = true
        noAnswerButton.layer.masksToBounds = true
        posterImageView.layer.cornerRadius = 20
        posterImageView.layer.masksToBounds = true
        activityIndicator.hidesWhenStopped = true
        
        
        questionTitleLabel.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        questionCounterLabel.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        yesAnswerButton.titleLabel?.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        noAnswerButton.titleLabel?.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        questionTextLabel.font = UIFont(name: "YS Display Bold", size: 23) ?? .systemFont(ofSize: 23, weight: .bold)
        
        presenter.viewController = self
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        showLoadingIndicator()
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    // MARK: - Actions
    
    @IBAction private func yesAnswerTapped(_ sender: UIButton) {
        presenter.yesAnswerTapped()
    }

    @IBAction private func noAnswerTapped(_ sender: UIButton) {
        presenter.noAnswerTapped()
    }

    // MARK: - Private UI
    private func restartGame() {
        presenter.resetQuestionIndex()
            correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
       }
    
    func show(quiz step: QuizStepViewData) {
        posterImageView.image = step.image
        questionTextLabel.text = step.question
        questionCounterLabel.text = step.questionNumber
        posterImageView.layer.borderWidth = 0
        presenter.switchToNextQuestion()
        hideLoadingIndicator()
    }
    func showResult(quiz result: QuizResultViewData) {
        let model = AlertModel(title: result.title,
                               text: result.text,
                               buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }

            self.restartGame()
            showLoadingIndicator()
        }
        
        AlertPresenter.show(in: self, model: model)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }

        posterImageView.layer.masksToBounds = true
        posterImageView.layer.borderWidth = 8
        posterImageView.layer.borderColor = (isCorrect ? UIColor.ypGreen : UIColor.ypRed).cgColor
        noAnswerButton.isEnabled = false
        yesAnswerButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            noAnswerButton.isEnabled = true
            yesAnswerButton.isEnabled = true
            self.showNextQuestionOrResults()
        }
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Private Helpers
    
    private func showNextQuestionOrResults() {
        
        
        if presenter.isLastQuestion() {
            
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let bestGame = statisticService.bestGame
            let result: QuizResultViewData = QuizResultViewData(
                title: "Этот раунд окончен!",
                text: """
                Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(presenter.questionsAmount) (\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """,
                buttonText: "Сыграть ещё раз")

            showResult(quiz: result)
        }else{
            questionFactory?.requestNextQuestion()
            showLoadingIndicator()
        }
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               text: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.loadData()
            self.questionFactory?.requestNextQuestion()
        }
        
        AlertPresenter.show(in: self, model: model)
    }
}
