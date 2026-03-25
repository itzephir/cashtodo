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

// MARK: - Business Logic (Interactor)

protocol OperationListBusinessLogic: AnyObject {
    func loadData()
    func deleteOperation(at indexPath: IndexPath)
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
