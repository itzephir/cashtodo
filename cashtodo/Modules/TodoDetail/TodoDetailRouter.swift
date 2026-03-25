import UIKit

final class TodoDetailRouter: TodoDetailRoutingLogic {

    // MARK: - VIPER references

    weak var viewController: UIViewController?

    // MARK: - TodoDetailRoutingLogic

    func dismiss() {
        guard let viewController else { return }

        if viewController.presentingViewController != nil {
            viewController.dismiss(animated: true)
        } else {
            viewController.navigationController?.popViewController(animated: true)
        }
    }
}
