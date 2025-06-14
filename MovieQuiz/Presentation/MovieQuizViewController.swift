import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    private var presenter: MovieQuizPresenter!
    private let alertPresenter = AlertPresenter()
    
    private var isButtonsUnlocked = true
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchLoadingIndicator(to: true)
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        resetBorderColor()
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
        resetBorderColor()
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        switchLoadingIndicator(to: false)
        
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let model = AlertModel(title: result.title,
                               message: message,
                               buttonText: result.buttonText) { [weak self] in
            self?.presenter.restartGame()
        }
        alertPresenter.show(alertModel: model, screen: self)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showNetworkError(message: String) {
        switchLoadingIndicator(to: false)
        
        let alertModel = AlertModel(title: "Ошибка загрузки", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
        }
        alertPresenter.show(alertModel: alertModel, screen: self)
        
    }
    
    func switchLoadingIndicator(to state: Bool) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = !state
            state ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
    
    func buttonLocker() {
        isButtonsUnlocked = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in // 0.2 для удобства тестирования
            guard let self = self else { return }
            self.isButtonsUnlocked = true
        }
        
    }
    
    private func resetBorderColor() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
}
