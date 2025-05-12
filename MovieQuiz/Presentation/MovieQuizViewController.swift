import UIKit



final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var isButtonsUnlocked = true
    
    private let alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
        resetBorderStyle()
        
        let statisticService = StatisticService()
        self.statisticService = statisticService
        
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isButtonsUnlocked else {return}
        guard let currentQuestion = currentQuestion else {return}
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard isButtonsUnlocked else {return}
        guard let currentQuestion = currentQuestion else {return}
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        show(quiz: viewModel)
    }
    
    private func buttonLocker() {
        isButtonsUnlocked = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isButtonsUnlocked = true
        }
        
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        buttonLocker()
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func resetBorderStyle() {
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = nil
    }
    
    private func resetGame() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.questionFactory?.resetQuestions()
        self.questionFactory?.requestNextQuestion()
    }
    @IBAction func resetStatistics(_ sender: UIButton) { // добавил это чтобы тестировать правильно ли считается статистика, в UI скрыто для ревью
        statisticService?.reset()
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: 10)
            let currentResult = correctAnswers == questionsAmount ?
            "Ваш результат: \(correctAnswers)/10" :
            "Вы ответили на \(correctAnswers)/10, попробуйте еще раз"
            let stasticsText = "Количество сыгранных квизов: \(statisticService?.totalGamesCount ?? 0) \n" +
            "Рекорд: \(statisticService?.bestGame.correct ?? 0)/10 \(statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString)\n" +
            "Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%"
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: currentResult + "\n" + stasticsText,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    self?.resetGame()
                }
            )
            alertPresenter.show(alertModel: alertModel, screen: self)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        resetBorderStyle()
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}
