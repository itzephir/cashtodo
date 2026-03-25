import UIKit

enum TodoDetailAssembly {
    static func build(todoId: UUID? = nil) -> UIViewController {
        let todoService = TodoService(coreDataStack: CoreDataStack.shared)
        let operationService = OperationService(coreDataStack: CoreDataStack.shared)

        let viewController = TodoDetailViewController()
        let interactor = TodoDetailInteractor(
            todoService: todoService,
            operationService: operationService
        )
        let presenter = TodoDetailPresenter()
        let router = TodoDetailRouter()

        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.view = viewController
        router.viewController = viewController

        interactor.todoId = todoId

        return viewController
    }
}
