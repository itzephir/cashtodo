import Foundation

final class OperationEditInteractor: OperationEditBusinessLogic, OperationEditDataStore {

    // MARK: - VIPER

    var presenter: OperationEditPresentationLogic?

    // MARK: - Data Store

    var operationId: UUID?

    // MARK: - Services

    private let operationService: OperationServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let todoService: TodoServiceProtocol

    // MARK: - State

    private var categories: [Category] = []
    private var todos: [TodoItem] = []
    private var existingOperation: FinancialOperation?

    // MARK: - Init

    init(
        operationService: OperationServiceProtocol,
        categoryService: CategoryServiceProtocol,
        todoService: TodoServiceProtocol
    ) {
        self.operationService = operationService
        self.categoryService = categoryService
        self.todoService = todoService
    }

    // MARK: - OperationEditBusinessLogic

    func loadData() {
        categories = categoryService.fetchAllCategories()
        todos = todoService.fetchIncompleteTodosWithPrice()

        let categoryItems = categories.map { category in
            CategoryPickerItem(
                id: category.id,
                name: category.name,
                iconName: category.iconName
            )
        }
        presenter?.presentCategories(categoryItems)

        let todoItems = todos.map { todo in
            TodoPickerItem(
                id: todo.id,
                title: todo.title
            )
        }
        presenter?.presentTodos(todoItems)

        if let operationId {
            let allOperations = operationService.fetchAllOperations()
            existingOperation = allOperations.first { $0.id == operationId }

            if let op = existingOperation {
                let categoryIndex = categories.firstIndex(where: { $0.id == op.category?.id }) ?? 0
                let todoIndex: Int? = {
                    guard let linkedTodo = op.todoItem else { return nil }
                    return todos.firstIndex(where: { $0.id == linkedTodo.id })
                }()

                let viewModel = OperationEditViewModel(
                    title: op.title,
                    amountText: op.amount.stringValue,
                    date: op.date,
                    selectedCategoryIndex: categoryIndex,
                    selectedTodoIndex: todoIndex
                )
                presenter?.presentOperationData(viewModel)
            }
        }
    }

    func saveOperation(
        title: String,
        amountText: String,
        date: Date,
        categoryIndex: Int,
        todoIndex: Int?
    ) {
        // Validation
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            presenter?.presentValidationError(L10n.errorEnterOpTitle)
            return
        }

        let sanitizedAmount = amountText.replacingOccurrences(of: ",", with: ".")
        let amount = NSDecimalNumber(string: sanitizedAmount)
        guard amount != NSDecimalNumber.notANumber,
              amount.compare(NSDecimalNumber.zero) == .orderedDescending else {
            presenter?.presentValidationError(L10n.errorInvalidAmount)
            return
        }

        guard categoryIndex >= 0, categoryIndex < categories.count else {
            presenter?.presentValidationError(L10n.errorSelectCategory)
            return
        }

        let category = categories[categoryIndex]
        let todoItem: TodoItem? = {
            guard let idx = todoIndex, idx >= 0, idx < todos.count else { return nil }
            return todos[idx]
        }()

        if let existingOperation {
            operationService.updateOperation(
                existingOperation,
                title: trimmedTitle,
                amount: amount,
                date: date,
                category: category,
                todoItem: todoItem
            )
        } else {
            operationService.createOperation(
                title: trimmedTitle,
                amount: amount,
                date: date,
                category: category,
                todoItem: todoItem
            )
        }

        presenter?.presentSaveSuccess()
    }
}
