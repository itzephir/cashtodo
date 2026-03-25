import UIKit

enum TodoListAssembly {
    static func build() -> UIViewController {
        let todoService = TodoService(coreDataStack: CoreDataStack.shared)

        let viewController = TodoListViewController()
        let interactor = TodoListInteractor(todoService: todoService)
        let presenter = TodoListPresenter()
        let router = TodoListRouter()

        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
