protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewData)
    func showResult(quiz result: QuizResultViewData)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
