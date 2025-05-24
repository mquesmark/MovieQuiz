import UIKit



final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        resetBorderStyle()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        
        switchLoadingIndicator(to: true)
        questionFactory?.loadData()
        
    }
    
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
    private func switchLoadingIndicator(to shown: Bool) {
        if shown {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    private func showNetworkError(message: String) {
        switchLoadingIndicator(to: false)
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.show(alertModel: alertModel, screen: self)
        
    }
    func didLoadDataFromServer() {
        switchLoadingIndicator(to: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadDataFromServer(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {return}
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        show(quiz: viewModel)
    }
    
    private func buttonLocker() {
        isButtonsUnlocked = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 0.2 для удобства тестирования
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in // 0.2 для удобства тестирования 
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
            
            let gamesCountText = "Количество сыграных квизов: \(statisticService?.totalGamesCount ?? 0)"
            let bestGameText = "Рекорд: \(statisticService?.bestGame.correct ?? 0)/10)"
            let bestGameDate = "\(statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString)"
            let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%"
            
            let message = [currentResult, gamesCountText, bestGameText, bestGameDate, accuracyText].joined(separator: "\n")
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
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
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}
