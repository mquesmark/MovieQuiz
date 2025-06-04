import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10

    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?

    private var alertPresenter = AlertPresenter()

    private var isButtonsUnlocked = true
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetBorderStyle()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        
        switchLoadingIndicator(to: true)
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {return}
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        switchLoadingIndicator(to: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadDataFromServer(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isButtonsUnlocked else {return}
        guard let currentQuestion else {return}
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard isButtonsUnlocked else {return}
        guard let currentQuestion = currentQuestion else {return}
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    // MARK: - Private functions
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        resetBorderStyle()
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        switchLoadingIndicator(to: false)

    }
    
    private func show(quiz result: QuizResultsViewModel) {
        var message = result.text
        if let statisticService = statisticService {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let bestGame = statisticService.bestGame
            
            let gamesCountText = "Количество сыграных квизов: \(statisticService.totalGamesCount)"
            let currentResult = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let bestGameText = "Рекорд: \(bestGame.correct)"
            let bestGameDate = "\(bestGame.date.dateTimeString)"
            let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            message = [currentResult, gamesCountText, bestGameText, bestGameDate, accuracyText].joined(separator: "\n")
        }
        
        let model = AlertModel(title: result.title,
                               message: message,
                               buttonText: result.buttonText) { [weak self] in
            self?.resetGame()
        }
        alertPresenter.show(alertModel: model, screen: self)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        buttonLocker()
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in // 0.2 для удобства тестирования
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Ваш результат: \(correctAnswers)/10" :
            "Вы ответили на \(correctAnswers)/10, попробуйте еще раз"
            
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                 text: text,
                                                 buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            switchLoadingIndicator(to: true)
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func showNetworkError(message: String) {
        switchLoadingIndicator(to: false)
        
        let alertModel = AlertModel(title: "Ошибка загрузки", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.loadData()
        }
        alertPresenter.show(alertModel: alertModel, screen: self)
        
    }

    // MARK: - Вспомогательные функции
    
    private func switchLoadingIndicator(to state: Bool) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = !state
            state ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
    
    private func buttonLocker() {
        isButtonsUnlocked = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 0.2 для удобства тестирования
            self.isButtonsUnlocked = true
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
        switchLoadingIndicator(to: true)
        self.questionFactory?.loadData()
    }
    
    @IBAction func resetStatistics(_ sender: UIButton) { // добавил это чтобы тестировать правильно ли считается статистика, в UI скрыто для ревью
        statisticService?.reset()
    }
}
