import UIKit

struct TodoDetailViewModel {
    let title: String
    let descriptionText: String
    let priceText: String
    let isCompleted: Bool
    let linkedOperations: [LinkedOperationViewModel]
    let isNewTodo: Bool
}

struct LinkedOperationViewModel {
    let id: UUID
    let title: String
    let amountText: String
    let categoryIcon: String
}

protocol TodoDetailBusinessLogic: AnyObject {
    func loadTodo()
    func saveTodo(title: String, descriptionText: String?, priceText: String?)
    func deleteTodo()
}

protocol TodoDetailDataStore: AnyObject {
    var todoId: UUID? { get set }
}

protocol TodoDetailPresentationLogic: AnyObject {
    func presentTodo(_ todo: TodoItem)
    func presentNewTodoForm()
    func presentSaveSuccess()
    func presentDeleteSuccess()
    func presentError(_ error: Error)
}

protocol TodoDetailDisplayLogic: AnyObject {
    func displayTodo(_ viewModel: TodoDetailViewModel)
    func displayNewTodoForm()
    func displaySaveSuccess()
    func displayDeleteSuccess()
    func displayError(_ message: String)
}

protocol TodoDetailRoutingLogic: AnyObject {
    func dismiss()
}
