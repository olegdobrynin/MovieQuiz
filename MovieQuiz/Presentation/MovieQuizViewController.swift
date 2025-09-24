import UIKit
import Foundation
// MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var questionTextLabel: UILabel!
    @IBOutlet private weak var questionCounterLabel: UILabel!
    @IBOutlet private weak var yesAnswerButton: UIButton!
    @IBOutlet private weak var noAnswerButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties
    
    private var presenter: MovieQuizPresenter!
     
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
        
        presenter = MovieQuizPresenter(viewController: self)
        
        questionTitleLabel.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        questionCounterLabel.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        yesAnswerButton.titleLabel?.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        noAnswerButton.titleLabel?.font = UIFont(name: "YS Display Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        questionTextLabel.font = UIFont(name: "YS Display Bold", size: 23) ?? .systemFont(ofSize: 23, weight: .bold)
        showLoadingIndicator()
    }

    // MARK: - Actions
    
    @IBAction private func yesAnswerTapped(_ sender: UIButton) {
        presenter.yesAnswerTapped()
    }

    @IBAction private func noAnswerTapped(_ sender: UIButton) {
        presenter.noAnswerTapped()
    }

    // MARK: - Private UI
    
    func show(quiz step: QuizStepViewData) {
        posterImageView.image = step.image
        questionTextLabel.text = step.question
        questionCounterLabel.text = step.questionNumber
        posterImageView.layer.borderWidth = 0
        presenter.switchToNextQuestion()
        hideLoadingIndicator()
    }
    func showResult(quiz result: QuizResultViewData) {
        let message = presenter.makeResultsMessage()
        
        let model = AlertModel(title: result.title,
                               text: message,
                               buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }

            self.presenter.restartGame()
            showLoadingIndicator()
        }
        
        AlertPresenter.show(in: self, model: model)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.borderWidth = 8
        posterImageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               text: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        AlertPresenter.show(in: self, model: model)
    }
    
}
