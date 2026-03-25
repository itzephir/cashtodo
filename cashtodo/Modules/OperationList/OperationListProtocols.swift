import UIKit

// MARK: - View Models

struct OperationListCellViewModel {
    let id: UUID
    let title: String
    let amountText: String
    let dateText: String
    let categoryIcon: String
    let categoryName: String
    let linkedTodoTitle: String?
}

struct DebtCellViewModel {
    let id: UUID
    let title: String
    let priceText: String
}

struct DebtHeaderViewModel {
    let totalDebtText: String
}

// MARK: - Date Filter

enum DateFilter: Equatable {
    case all
    case today
    case week
    case month
    case custom(from: Date, to: Date)

    var title: String {
        switch self {
        case .all: L10n.filterAll
        case .today: L10n.filterToday
        case .week: L10n.filterWeek
        case .month: L10n.filterMonth
        case .custom: L10n.filterPeriod
        }
    }

    static var presets: [DateFilter] { [.all, .today, .week, .month] }
}

// MARK: - Business Logic (Interactor)

protocol OperationListBusinessLogic: AnyObject {
    func loadData()
    func deleteOperation(at indexPath: IndexPath)
    func applyFilter(_ filter: DateFilter)
}

// MARK: - Data Store

protocol OperationListDataStore: AnyObject {}

// MARK: - Presentation Logic (Presenter -> View)

protocol OperationListPresentationLogic: AnyObject {
    func presentData(
        operations: [FinancialOperation],
        categories: [Category],
        debtTodos: [TodoItem]
    )
}

// MARK: - Display Logic (View)

protocol OperationListDisplayLogic: AnyObject {
    func displayDebtHeader(_ viewModel: DebtHeaderViewModel)
    func displayDebtItems(_ viewModels: [DebtCellViewModel])
    func displayOperationSections(
        _ sections: [(categoryName: String, categoryIcon: String, operations: [OperationListCellViewModel])]
    )
}

// MARK: - Routing Logic

protocol OperationListRoutingLogic: AnyObject {
    func navigateToCreate()
    func navigateToEdit(operationId: UUID)
    func navigateToTodoDetail(todoId: UUID)
}
