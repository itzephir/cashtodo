import Foundation

final class TodoListPresenter: TodoListPresentationLogic {

    // MARK: - VIPER

    weak var view: TodoListDisplayLogic?

    // MARK: - Private

    private let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()

    // MARK: - TodoListPresentationLogic

    func presentTodos(_ todos: [TodoItem]) {
        let viewModels = todos.map { todo in
            TodoListCellViewModel(
                id: todo.id,
                title: todo.title,
                isCompleted: todo.isCompleted,
                priceText: todo.price.flatMap { priceFormatter.string(from: $0) },
                hasLinkedOperations: (todo.operations?.count ?? 0) > 0
            )
        }
        view?.displayTodos(viewModels)
    }

    func presentError(_ error: Error) {
        view?.displayError(error.localizedDescription)
    }
}
