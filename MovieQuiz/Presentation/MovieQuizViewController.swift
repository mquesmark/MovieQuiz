import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var statisticService: StatisticServiceProtocol?

    private var presenter: MovieQuizPresenter!
    private let alertPresenter = AlertPresenter()

    private var isButtonsUnlocked = true
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchLoadingIndicator(to: true)
        presenter = MovieQuizPresenter(viewController: self)
        resetBorderStyle()
        statisticService = StatisticService()
        
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isButtonsUnlocked else {return}
        
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard isButtonsUnlocked else {return}
        
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private functions

    func show(quiz step: QuizStepViewModel) {
        resetBorderStyle()
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        switchLoadingIndicator(to: false)

    }
    
    func show(quiz result: QuizResultsViewModel) {
        var message = result.text
        if let statisticService = statisticService {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            
            let bestGame = statisticService.bestGame
            
            let gamesCountText = "Количество сыграных квизов: \(statisticService.totalGamesCount)"
            let currentResult = "Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)"
            let bestGameText = "Рекорд: \(bestGame.correct)"
            let bestGameDate = "\(bestGame.date.dateTimeString)"
            let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            message = [currentResult, gamesCountText, bestGameText, bestGameDate, accuracyText].joined(separator: "\n")
        }
        
        let model = AlertModel(title: result.title,
                               message: message,
                               buttonText: result.buttonText) { [weak self] in
            self?.presenter.restartGame()
        }
        alertPresenter.show(alertModel: model, screen: self)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        buttonLocker()
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in // 0.2 для удобства тестирования
            guard let self else { return }

            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let text = presenter.correctAnswers == presenter.questionsAmount ?
            "Ваш результат: \(presenter.correctAnswers)/10"
            :
            "Вы ответили на \(presenter.correctAnswers)/10, попробуйте еще раз"
            
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                 text: text,
                                                 buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            switchLoadingIndicator(to: true)
        }
    }
    
    func showNetworkError(message: String) {
        switchLoadingIndicator(to: false)
        
        let alertModel = AlertModel(title: "Ошибка загрузки", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
        }
        alertPresenter.show(alertModel: alertModel, screen: self)
        
    }

    // MARK: - Вспомогательные функции
    
    func switchLoadingIndicator(to state: Bool) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = !state
            state ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
    
    private func buttonLocker() {
        isButtonsUnlocked = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in // 0.2 для удобства тестирования
            guard let self = self else {
                print("self is nil")
                return
            }// 0.2 для удобства тестирования
            self.isButtonsUnlocked = true
        }
        
    }

    private func resetBorderStyle() {
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = nil
    }
    
    @IBAction func resetStatistics(_ sender: UIButton) { // добавил это чтобы тестировать правильно ли считается статистика, в UI скрыто для ревью
        statisticService?.reset()
    }
}
