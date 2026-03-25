import Foundation

final class TodoDetailInteractor: TodoDetailBusinessLogic, TodoDetailDataStore {

    // MARK: - VIPER references

    var presenter: TodoDetailPresentationLogic?

    // MARK: - Data Store

    var todoId: UUID?

    // MARK: - Services

    private let todoService: TodoServiceProtocol
    private let operationService: OperationServiceProtocol

    // MARK: - Init

    init(todoService: TodoServiceProtocol, operationService: OperationServiceProtocol) {
        self.todoService = todoService
        self.operationService = operationService
    }

    // MARK: - TodoDetailBusinessLogic

    func loadTodo() {
        guard let todoId else {
            presenter?.presentNewTodoForm()
            return
        }

        guard let todo = todoService.fetchTodo(by: todoId) else {
            presenter?.presentError(TodoDetailError.todoNotFound)
            return
        }

        presenter?.presentTodo(todo)
    }

    func saveTodo(title: String, descriptionText: String?, priceText: String?) {
        let price: NSDecimalNumber?
        if let priceText, !priceText.isEmpty {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = Locale.current
            if let number = formatter.number(from: priceText) {
                price = NSDecimalNumber(decimal: number.decimalValue)
            } else {
                // Try with dot as decimal separator as fallback
                price = NSDecimalNumber(string: priceText)
                if price == NSDecimalNumber.notANumber {
                    presenter?.presentError(TodoDetailError.invalidPrice)
                    return
                }
            }
        } else {
            price = nil
        }

        if let todoId, let todo = todoService.fetchTodo(by: todoId) {
            todoService.updateTodo(todo, title: title, descriptionText: descriptionText, price: price)
        } else {
            let newTodo = todoService.createTodo(title: title, descriptionText: descriptionText, price: price)
            self.todoId = newTodo.id
        }

        presenter?.presentSaveSuccess()
    }

    func deleteTodo() {
        guard let todoId, let todo = todoService.fetchTodo(by: todoId) else {
            presenter?.presentError(TodoDetailError.todoNotFound)
            return
        }

        todoService.deleteTodo(todo)
        presenter?.presentDeleteSuccess()
    }
}

// MARK: - Errors

enum TodoDetailError: LocalizedError {
    case todoNotFound
    case invalidPrice

    var errorDescription: String? {
        switch self {
        case .todoNotFound:
            return "Задача не найдена"
        case .invalidPrice:
            return "Некорректная цена"
        }
    }
}
