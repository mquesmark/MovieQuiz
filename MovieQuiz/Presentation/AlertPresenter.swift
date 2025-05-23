import UIKit
final class AlertPresenter {
    func show(alertModel: AlertModel, screen: UIViewController) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: alertModel.buttonText, style: .default){ _ in
            alertModel.completion()
        }
        alert.addAction(action)
        screen.present(alert, animated: true)
    }
}
