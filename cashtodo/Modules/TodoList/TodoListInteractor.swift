import Foundation

final class TodoListInteractor: TodoListBusinessLogic, TodoListDataStore {

    // MARK: - VIPER

    var presenter: TodoListPresentationLogic?

    // MARK: - Data Store

    private(set) var todos: [TodoItem] = []

    // MARK: - Dependencies

    private let todoService: TodoServiceProtocol
    private let operationService: OperationServiceProtocol
    private let categoryService: CategoryServiceProtocol

    // MARK: - Init

    init(
        todoService: TodoServiceProtocol,
        operationService: OperationServiceProtocol,
        categoryService: CategoryServiceProtocol
    ) {
        self.todoService = todoService
        self.operationService = operationService
        self.categoryService = categoryService
    }

    // MARK: - TodoListBusinessLogic

    func loadTodos() {
        todos = todoService.fetchAllTodos()
        presenter?.presentTodos(todos)
    }

    func deleteTodo(at index: Int) {
        guard index >= 0, index < todos.count else { return }
        let todo = todos[index]
        todoService.deleteTodo(todo)
        loadTodos()
    }

    func toggleCompletion(at index: Int) {
        guard index >= 0, index < todos.count else { return }
        let todo = todos[index]
        let wasCompleted = todo.isCompleted
        todoService.toggleCompletion(todo)

        // When completing a todo with price, create a financial operation
        if !wasCompleted, let price = todo.price, price.compare(NSDecimalNumber.zero) == .orderedDescending {
            let defaultCategory = categoryService.fetchAllCategories().first
            if let category = defaultCategory {
                operationService.createOperation(
                    title: todo.title,
                    amount: price,
                    date: Date(),
                    category: category,
                    todoItem: todo
                )
            }
        }

        loadTodos()
    }
}
