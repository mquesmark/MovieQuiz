import UIKit

final class MovieQuizPresenter {
    // Превая часть
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    
    // Вторая часть
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func noButtonClicked() {
        guard let currentQuestion else { return }
        
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    func yesButtonClicked() {
        guard let currentQuestion else { return }
        
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
}
