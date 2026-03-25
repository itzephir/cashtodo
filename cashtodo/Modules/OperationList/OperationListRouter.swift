import UIKit

final class OperationListRouter: OperationListRoutingLogic {

    // MARK: - VIPER

    weak var viewController: UIViewController?

    // MARK: - OperationListRoutingLogic

    func navigateToCreate() {
        let editVC = OperationEditAssembly.build()
        let nav = UINavigationController(rootViewController: editVC)
        viewController?.present(nav, animated: true)
    }

    func navigateToEdit(operationId: UUID) {
        let editVC = OperationEditAssembly.build(operationId: operationId)
        let nav = UINavigationController(rootViewController: editVC)
        viewController?.present(nav, animated: true)
    }

    func navigateToTodoDetail(todoId: UUID) {
        let detailVC = TodoDetailAssembly.build(todoId: todoId)
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}
