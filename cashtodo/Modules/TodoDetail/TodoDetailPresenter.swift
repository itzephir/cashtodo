import Foundation

final class TodoDetailPresenter: TodoDetailPresentationLogic {

    // MARK: - VIPER references

    weak var view: TodoDetailDisplayLogic?

    // MARK: - Currency formatter

    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()

    // MARK: - TodoDetailPresentationLogic

    func presentTodo(_ todo: TodoItem) {
        let priceText: String
        if let price = todo.price {
            priceText = currencyFormatter.string(from: price) ?? price.stringValue
        } else {
            priceText = ""
        }

        let operations = (todo.operations?.allObjects as? [FinancialOperation]) ?? []
        let operationViewModels = operations
            .sorted { $0.date > $1.date }
            .map { operation in
                let amountText = currencyFormatter.string(from: operation.amount)
                    ?? operation.amount.stringValue
                return LinkedOperationViewModel(
                    id: operation.id,
                    title: operation.title,
                    amountText: amountText,
                    categoryIcon: operation.category?.iconName ?? "tag"
                )
            }

        let viewModel = TodoDetailViewModel(
            title: todo.title,
            descriptionText: todo.descriptionText ?? "",
            priceText: priceText,
            isCompleted: todo.isCompleted,
            linkedOperations: operationViewModels,
            isNewTodo: false
        )

        view?.displayTodo(viewModel)
    }

    func presentNewTodoForm() {
        view?.displayNewTodoForm()
    }

    func presentSaveSuccess() {
        view?.displaySaveSuccess()
    }

    func presentDeleteSuccess() {
        view?.displayDeleteSuccess()
    }

    func presentError(_ error: Error) {
        view?.displayError(error.localizedDescription)
    }
}
