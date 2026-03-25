import UIKit

enum OperationEditAssembly {
    static func build(operationId: UUID? = nil) -> UIViewController {
        let coreDataStack = CoreDataStack.shared

        let operationService = OperationService(coreDataStack: coreDataStack)
        let categoryService = CategoryService(coreDataStack: coreDataStack)
        let todoService = TodoService(coreDataStack: coreDataStack)

        let viewController = OperationEditViewController()
        let presenter = OperationEditPresenter()
        let interactor = OperationEditInteractor(
            operationService: operationService,
            categoryService: categoryService,
            todoService: todoService
        )
        let router = OperationEditRouter()

        interactor.operationId = operationId

        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController

        return viewController
    }
}
