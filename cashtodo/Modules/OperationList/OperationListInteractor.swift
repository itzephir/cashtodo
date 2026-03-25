import UIKit

final class OperationListInteractor: OperationListBusinessLogic, OperationListDataStore {

    // MARK: - VIPER

    var presenter: OperationListPresentationLogic?

    // MARK: - Services

    private let operationService: OperationServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let todoService: TodoServiceProtocol

    // MARK: - State

    private var operations: [FinancialOperation] = []
    private var categories: [Category] = []
    private var debtTodos: [TodoItem] = []

    /// Grouped operations keyed by category, keeping order consistent with `categories`.
    private var groupedOperations: [(category: Category, operations: [FinancialOperation])] = []

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

    // MARK: - OperationListBusinessLogic

    func loadData() {
        operations = operationService.fetchAllOperations()
        categories = categoryService.fetchAllCategories()
        debtTodos = todoService.fetchIncompleteTodosWithPrice()

        groupOperations()

        presenter?.presentData(
            operations: operations,
            categories: categories,
            debtTodos: debtTodos
        )
    }

    func deleteOperation(at indexPath: IndexPath) {
        let sectionIndex = indexPath.section - 1
        guard sectionIndex >= 0, sectionIndex < groupedOperations.count else { return }
        let ops = groupedOperations[sectionIndex].operations
        guard indexPath.row < ops.count else { return }

        let operation = ops[indexPath.row]
        operationService.deleteOperation(operation)
        loadData()
    }

    // MARK: - Private

    private func groupOperations() {
        var dict: [UUID: [FinancialOperation]] = [:]

        for operation in operations {
            let key = operation.category?.id ?? UUID()
            dict[key, default: []].append(operation)
        }

        groupedOperations = categories.compactMap { category in
            let id = category.id
            guard let ops = dict[id], !ops.isEmpty else { return nil }
            return (category: category, operations: ops)
        }
    }
}
