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

    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = AlertPresenter()
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
        
        questionTitleLabel.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        questionCounterLabel.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        yesAnswerButton.titleLabel?.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        noAnswerButton.titleLabel?.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        questionTextLabel.font = UIFont(name: "YS Display Bold", size: 23) ?? .systemFont(ofSize: 23, weight: .bold)
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        self.questionFactory?.initGame()
        self.questionFactory?.requestNextQuestion()
                
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = makeStepViewData(from: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        
    }
    // MARK: - Actions
    
    @IBAction private func yesAnswerTapped(_ sender: UIButton) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }

    @IBAction private func noAnswerTapped(_ sender: UIButton) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }

    // MARK: - Private UI
    private func restartGame() {
            currentQuestionIndex = 0
            correctAnswers = 0
            self.questionFactory?.initGame()
            self.questionFactory?.requestNextQuestion()
       }
    
    private func show(quiz step: QuizStepViewData) {
        posterImageView.image = step.image
        questionTextLabel.text = step.question
        questionCounterLabel.text = step.questionNumber
        posterImageView.layer.borderWidth = 0
        currentQuestionIndex += 1
    }
    private func show(quiz result: QuizResultViewData) {
        let model = AlertModel(title: result.title,
                               text: result.text,
                               buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }

            self.restartGame()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
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

    // MARK: - Private Helpers
    
    private func showNextQuestionOrResults() {
        questionFactory?.requestNextQuestion()
        
        if currentQuestionIndex == questionsAmount {
            
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let bestGame = statisticService.bestGame
            let result: QuizResultViewData = QuizResultViewData(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)\n Количество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(questionsAmount) (\(bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
                buttonText: "Сыграть ещё раз")

            show(quiz: result)
        }
    }

    private func makeStepViewData(from model: QuizQuestion) -> QuizStepViewData {
        QuizStepViewData(
            image: UIImage(named: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}
