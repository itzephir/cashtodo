import Foundation

final class TodoListInteractor: TodoListBusinessLogic, TodoListDataStore {

    // MARK: - VIPER

    var presenter: TodoListPresentationLogic?

    // MARK: - Data Store

    private(set) var todos: [TodoItem] = []

    // MARK: - Dependencies

    private let todoService: TodoServiceProtocol

    // MARK: - Init

    init(todoService: TodoServiceProtocol) {
        self.todoService = todoService
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
        todoService.toggleCompletion(todo)
        loadTodos()
    }
}
