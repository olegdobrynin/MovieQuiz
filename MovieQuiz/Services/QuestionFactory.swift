import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    private var questions: [QuizQuestion]?
    weak var delegate: QuestionFactoryDelegate?
    
    func initGame() {
        questions = QuizQuestion.mocks()
    }
    
    func requestNextQuestion() {
        guard let index = questions?.indices.randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        delegate?.didReceiveNextQuestion(question: questions!.remove(at: index))
    }
    
}
