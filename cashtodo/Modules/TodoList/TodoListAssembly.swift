import UIKit

enum TodoListAssembly {
    static func build() -> UIViewController {
        let stack = CoreDataStack.shared
        let todoService = TodoService(coreDataStack: stack)
        let operationService = OperationService(coreDataStack: stack)
        let categoryService = CategoryService(coreDataStack: stack)

        let viewController = TodoListViewController()
        let interactor = TodoListInteractor(
            todoService: todoService,
            operationService: operationService,
            categoryService: categoryService
        )
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
