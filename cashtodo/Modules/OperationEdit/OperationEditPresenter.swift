import Foundation

final class OperationEditPresenter: OperationEditPresentationLogic {

    // MARK: - VIPER

    weak var viewController: OperationEditDisplayLogic?

    // MARK: - OperationEditPresentationLogic

    func presentCategories(_ categories: [CategoryPickerItem]) {
        viewController?.displayCategories(categories)
    }

    func presentTodos(_ todos: [TodoPickerItem]) {
        viewController?.displayTodos(todos)
    }

    func presentOperationData(_ viewModel: OperationEditViewModel) {
        viewController?.displayOperationData(viewModel)
    }

    func presentValidationError(_ message: String) {
        viewController?.displayValidationError(message)
    }

    func presentSaveSuccess() {
        viewController?.displaySaveSuccess()
    }
}
