import UIKit

final class OperationListInteractor: OperationListBusinessLogic, OperationListDataStore {

    // MARK: - VIPER

    var presenter: OperationListPresentationLogic?

    // MARK: - Services

    private let operationService: OperationServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let todoService: TodoServiceProtocol

    // MARK: - State

    private var allOperations: [FinancialOperation] = []
    private var filteredOperations: [FinancialOperation] = []
    private var categories: [Category] = []
    private var debtTodos: [TodoItem] = []
    private var currentFilter: DateFilter = .all

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
        allOperations = operationService.fetchAllOperations()
        categories = categoryService.fetchAllCategories()
        debtTodos = todoService.fetchIncompleteTodosWithPrice()

        applyCurrentFilter()
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

    func applyFilter(_ filter: DateFilter) {
        currentFilter = filter
        applyCurrentFilter()
    }

    // MARK: - Private

    private func applyCurrentFilter() {
        filteredOperations = filterOperations(allOperations, by: currentFilter)
        groupOperations()

        presenter?.presentData(
            operations: filteredOperations,
            categories: categories,
            debtTodos: debtTodos
        )
    }

    private func filterOperations(_ operations: [FinancialOperation], by filter: DateFilter) -> [FinancialOperation] {
        let calendar = Calendar.current
        let now = Date()

        switch filter {
        case .all:
            return operations
        case .today:
            let start = calendar.startOfDay(for: now)
            return operations.filter { $0.date >= start }
        case .week:
            guard let start = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: now)) else {
                return operations
            }
            return operations.filter { $0.date >= start }
        case .month:
            guard let start = calendar.date(byAdding: .month, value: -1, to: calendar.startOfDay(for: now)) else {
                return operations
            }
            return operations.filter { $0.date >= start }
        case .custom(let from, let to):
            let startOfFrom = calendar.startOfDay(for: from)
            var endComponents = DateComponents()
            endComponents.day = 1
            let endOfTo = calendar.date(byAdding: endComponents, to: calendar.startOfDay(for: to)) ?? to
            return operations.filter { $0.date >= startOfFrom && $0.date < endOfTo }
        }
    }

    private func groupOperations() {
        var dict: [UUID: [FinancialOperation]] = [:]

        for operation in filteredOperations {
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
