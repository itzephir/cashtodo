import Foundation

// MARK: - View Models

struct OperationEditViewModel {
    let title: String
    let amountText: String
    let date: Date
    let selectedCategoryIndex: Int
    let selectedTodoIndex: Int?
}

struct CategoryPickerItem {
    let id: UUID
    let name: String
    let iconName: String
}

struct TodoPickerItem {
    let id: UUID
    let title: String
}

// MARK: - Business Logic (Interactor)

protocol OperationEditBusinessLogic: AnyObject {
    func loadData()
    func saveOperation(
        title: String,
        amountText: String,
        date: Date,
        categoryIndex: Int,
        todoIndex: Int?
    )
}

// MARK: - Data Store

protocol OperationEditDataStore: AnyObject {
    var operationId: UUID? { get set }
}

// MARK: - Presentation Logic (Presenter -> View)

protocol OperationEditPresentationLogic: AnyObject {
    func presentCategories(_ categories: [CategoryPickerItem])
    func presentTodos(_ todos: [TodoPickerItem])
    func presentOperationData(_ viewModel: OperationEditViewModel)
    func presentValidationError(_ message: String)
    func presentSaveSuccess()
}

// MARK: - Display Logic (View)

protocol OperationEditDisplayLogic: AnyObject {
    func displayCategories(_ categories: [CategoryPickerItem])
    func displayTodos(_ todos: [TodoPickerItem])
    func displayOperationData(_ viewModel: OperationEditViewModel)
    func displayValidationError(_ message: String)
    func displaySaveSuccess()
}

// MARK: - Routing Logic

protocol OperationEditRoutingLogic: AnyObject {
    func dismiss()
}
