import Foundation

enum L10n {
    // MARK: - Tabs & Navigation
    static let tabTodos = NSLocalizedString("tab.todos", comment: "")
    static let tabFinance = NSLocalizedString("tab.finance", comment: "")
    static let todoTitle = NSLocalizedString("todo.title", comment: "")
    static let financeTitle = NSLocalizedString("finance.title", comment: "")
    static let operationTitle = NSLocalizedString("operation.title", comment: "")
    static let todoNew = NSLocalizedString("todo.new", comment: "")

    // MARK: - Buttons
    static let buttonSave = NSLocalizedString("button.save", comment: "")
    static let buttonCancel = NSLocalizedString("button.cancel", comment: "")
    static let buttonDelete = NSLocalizedString("button.delete", comment: "")
    static let buttonApply = NSLocalizedString("button.apply", comment: "")
    static let buttonOK = NSLocalizedString("button.ok", comment: "")

    // MARK: - Labels & Placeholders
    static let labelName = NSLocalizedString("label.name", comment: "")
    static let labelDescription = NSLocalizedString("label.description", comment: "")
    static let labelPrice = NSLocalizedString("label.price", comment: "")
    static let labelAmount = NSLocalizedString("label.amount", comment: "")
    static let labelDate = NSLocalizedString("label.date", comment: "")
    static let labelCategory = NSLocalizedString("label.category", comment: "")
    static let labelLinkedTask = NSLocalizedString("label.linkedTask", comment: "")
    static let labelLinkedOps = NSLocalizedString("label.linkedOps", comment: "")
    static let labelFrom = NSLocalizedString("label.from", comment: "")
    static let labelTo = NSLocalizedString("label.to", comment: "")
    static let labelNone = NSLocalizedString("label.none", comment: "")
    static let placeholderPrice = NSLocalizedString("placeholder.price", comment: "")

    // MARK: - Empty State
    static let emptyTodos = NSLocalizedString("empty.todos", comment: "")
    static let emptyLinkedOps = NSLocalizedString("empty.linkedOps", comment: "")

    // MARK: - Errors & Alerts
    static let errorTitle = NSLocalizedString("error.title", comment: "")
    static let errorTodoNotFound = NSLocalizedString("error.todoNotFound", comment: "")
    static let errorInvalidPrice = NSLocalizedString("error.invalidPrice", comment: "")
    static let errorEmptyTitle = NSLocalizedString("error.emptyTitle", comment: "")
    static let errorInvalidAmount = NSLocalizedString("error.invalidAmount", comment: "")
    static let errorSelectCategory = NSLocalizedString("error.selectCategory", comment: "")
    static let errorEnterOpTitle = NSLocalizedString("error.enterOpTitle", comment: "")
    static let alertDeleteTask = NSLocalizedString("alert.deleteTask", comment: "")
    static let alertCannotUndo = NSLocalizedString("alert.cannotUndo", comment: "")

    // MARK: - Date Filters
    static let filterAll = NSLocalizedString("filter.all", comment: "")
    static let filterToday = NSLocalizedString("filter.today", comment: "")
    static let filterWeek = NSLocalizedString("filter.week", comment: "")
    static let filterMonth = NSLocalizedString("filter.month", comment: "")
    static let filterPeriod = NSLocalizedString("filter.period", comment: "")

    // MARK: - Dynamic
    static func debtHeader(_ amount: String) -> String {
        String(format: NSLocalizedString("debt.header", comment: ""), amount)
    }

    // MARK: - Default Categories
    static let categoryFood = NSLocalizedString("category.food", comment: "")
    static let categoryTransport = NSLocalizedString("category.transport", comment: "")
    static let categoryShopping = NSLocalizedString("category.shopping", comment: "")
    static let categoryEntertainment = NSLocalizedString("category.entertainment", comment: "")
    static let categoryBills = NSLocalizedString("category.bills", comment: "")
    static let categoryHealth = NSLocalizedString("category.health", comment: "")
    static let categoryOther = NSLocalizedString("category.other", comment: "")
}
