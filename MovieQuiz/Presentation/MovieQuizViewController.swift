import UIKit

// MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController {

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
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
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

        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = makeStepViewData(from: firstQuestion)
            show(quiz: viewModel)
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
    
    private func show(quiz step: QuizStepViewData) {
        posterImageView.image = step.image
        questionTextLabel.text = step.question
        questionCounterLabel.text = step.questionNumber
        posterImageView.layer.borderWidth = 0
    }

    private func show(quiz result: QuizResultViewData) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            if let first = currentQuestion {
                self.show(quiz: self.makeStepViewData(from: first))
            }
        }

        alert.addAction(action)
        present(alert, animated: true)
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }

        posterImageView.layer.masksToBounds = true
        posterImageView.layer.borderWidth = 8
        posterImageView.layer.borderColor = (isCorrect ? UIColor.ypGreen : UIColor.ypRed).cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }

    // MARK: - Private Helpers
    
    private func showNextQuestionOrResults() {
        self.currentQuestion = questionFactory.requestNextQuestion()
        
        if currentQuestionIndex == questionsAmount - 1 {
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let viewModel = QuizResultViewData(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            guard let next = currentQuestion else { return }
            show(quiz: makeStepViewData(from: next))
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
