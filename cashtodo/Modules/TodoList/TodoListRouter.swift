import UIKit

final class TodoListRouter: TodoListRoutingLogic {

    // MARK: - VIPER

    weak var viewController: UIViewController?

    // MARK: - TodoListRoutingLogic

    func navigateToDetail(todoId: UUID) {
        let detailVC = TodoDetailAssembly.build(todoId: todoId)
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }

    func navigateToCreate() {
        let createVC = TodoDetailAssembly.build(todoId: nil)
        let nav = UINavigationController(rootViewController: createVC)
        viewController?.present(nav, animated: true)
    }
}
