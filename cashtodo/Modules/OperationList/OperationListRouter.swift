import UIKit

final class OperationListRouter: OperationListRoutingLogic {

    // MARK: - VIPER

    weak var viewController: UIViewController?

    // MARK: - OperationListRoutingLogic

    func navigateToCreate() {
        let editViewController = OperationEditAssembly.build()
        let nav = UINavigationController(rootViewController: editViewController)
        nav.modalPresentationStyle = .fullScreen
        viewController?.present(nav, animated: true)
    }

    func navigateToEdit(operationId: UUID) {
        let editViewController = OperationEditAssembly.build(operationId: operationId)
        let nav = UINavigationController(rootViewController: editViewController)
        nav.modalPresentationStyle = .fullScreen
        viewController?.present(nav, animated: true)
    }

    func navigateToTodoDetail(todoId: UUID) {
        let detailViewController = TodoDetailAssembly.build(todoId: todoId)
        viewController?.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
