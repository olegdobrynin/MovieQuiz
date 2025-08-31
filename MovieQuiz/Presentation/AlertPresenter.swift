import Foundation
import UIKit

final class AlertPresenter {
    static func show(in vc: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert)

        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }

        alert.addAction(action)

        vc.present(alert, animated: true, completion: nil)
    }
}
