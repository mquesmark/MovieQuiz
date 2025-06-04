protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func switchLoadingIndicator(to state: Bool)
    func buttonLocker()
    
    func showNetworkError(message: String)
}
