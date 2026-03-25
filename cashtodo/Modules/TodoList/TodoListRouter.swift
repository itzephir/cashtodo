import UIKit

final class TodoListRouter: TodoListRoutingLogic {

    // MARK: - VIPER

    weak var viewController: UIViewController?

    // MARK: - TodoListRoutingLogic

    func navigateToDetail(todoId: UUID) {
        let detailViewController = TodoDetailAssembly.build(todoId: todoId)
        viewController?.navigationController?.pushViewController(detailViewController, animated: true)
    }

    func navigateToCreate() {
        let createViewController = TodoDetailAssembly.build(todoId: nil)
        let nav = UINavigationController(rootViewController: createViewController)
        nav.modalPresentationStyle = .fullScreen
        viewController?.present(nav, animated: true)
    }
}
