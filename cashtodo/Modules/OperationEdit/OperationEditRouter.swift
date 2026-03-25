import UIKit

final class OperationEditRouter: OperationEditRoutingLogic {

    // MARK: - VIPER

    weak var viewController: UIViewController?

    // MARK: - OperationEditRoutingLogic

    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
