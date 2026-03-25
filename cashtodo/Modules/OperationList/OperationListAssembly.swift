import UIKit

enum OperationListAssembly {
    static func build() -> UIViewController {
        let coreDataStack = CoreDataStack.shared

        let operationService = OperationService(coreDataStack: coreDataStack)
        let categoryService = CategoryService(coreDataStack: coreDataStack)
        let todoService = TodoService(coreDataStack: coreDataStack)

        let viewController = OperationListViewController()
        let presenter = OperationListPresenter()
        let interactor = OperationListInteractor(
            operationService: operationService,
            categoryService: categoryService,
            todoService: todoService
        )
        let router = OperationListRouter()

        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController

        return viewController
    }
}
