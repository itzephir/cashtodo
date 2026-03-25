import UIKit

struct TodoListCellViewModel {
    let id: UUID
    let title: String
    let isCompleted: Bool
    let priceText: String?
    let hasLinkedOperations: Bool
}

protocol TodoListBusinessLogic: AnyObject {
    func loadTodos()
    func deleteTodo(at index: Int)
    func toggleCompletion(at index: Int)
}

protocol TodoListDataStore: AnyObject {
    var todos: [TodoItem] { get }
}

protocol TodoListPresentationLogic: AnyObject {
    func presentTodos(_ todos: [TodoItem])
    func presentError(_ error: Error)
}

protocol TodoListDisplayLogic: AnyObject {
    func displayTodos(_ viewModels: [TodoListCellViewModel])
    func displayError(_ message: String)
}

protocol TodoListRoutingLogic: AnyObject {
    func navigateToDetail(todoId: UUID)
    func navigateToCreate()
}
