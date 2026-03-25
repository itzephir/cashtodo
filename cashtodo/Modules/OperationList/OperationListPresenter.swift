import Foundation

final class OperationListPresenter: OperationListPresentationLogic {

    // MARK: - VIPER

    weak var viewController: OperationListDisplayLogic?

    // MARK: - Formatters

    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    // MARK: - OperationListPresentationLogic

    func presentData(
        operations: [FinancialOperation],
        categories: [Category],
        debtTodos: [TodoItem]
    ) {
        // Debt header
        let totalDebt = debtTodos.reduce(NSDecimalNumber.zero) { result, todo in
            result.adding(todo.price ?? .zero)
        }
        let totalDebtText = currencyFormatter.string(from: totalDebt) ?? "0"
        let debtHeader = DebtHeaderViewModel(totalDebtText: L10n.debtHeader(totalDebtText))
        viewController?.displayDebtHeader(debtHeader)

        // Debt items
        let debtViewModels = debtTodos.map { todo in
            DebtCellViewModel(
                id: todo.id,
                title: todo.title,
                priceText: currencyFormatter.string(from: todo.price ?? .zero) ?? "0"
            )
        }
        viewController?.displayDebtItems(debtViewModels)

        // Group operations by category
        var grouped: [UUID: (category: Category, operations: [FinancialOperation])] = [:]
        for operation in operations {
            guard let category = operation.category else { continue }
            let catId = category.id
            if grouped[catId] == nil {
                grouped[catId] = (category: category, operations: [])
            }
            grouped[catId]?.operations.append(operation)
        }

        // Sort sections by category name
        let sortedSections = categories.compactMap { category -> (categoryName: String, categoryIcon: String, operations: [OperationListCellViewModel])? in
            let catId = category.id
            guard let group = grouped[catId] else { return nil }
            let operationViewModels = group.operations.map { op in
                OperationListCellViewModel(
                    id: op.id,
                    title: op.title,
                    amountText: currencyFormatter.string(from: op.amount) ?? "0",
                    dateText: dateFormatter.string(from: op.date),
                    categoryIcon: category.iconName,
                    categoryName: category.name,
                    linkedTodoTitle: op.todoItem?.title
                )
            }
            return (
                categoryName: category.name,
                categoryIcon: category.iconName,
                operations: operationViewModels
            )
        }

        viewController?.displayOperationSections(sortedSections)
    }
}
