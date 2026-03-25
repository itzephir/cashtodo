import CoreData

protocol OperationServiceProtocol {
    func fetchAllOperations() -> [FinancialOperation]
    func fetchOperations(for todo: TodoItem) -> [FinancialOperation]
    @discardableResult
    func createOperation(title: String, amount: NSDecimalNumber, date: Date, category: Category, todoItem: TodoItem?) -> FinancialOperation
    func updateOperation(_ operation: FinancialOperation, title: String, amount: NSDecimalNumber, date: Date, category: Category, todoItem: TodoItem?)
    func deleteOperation(_ operation: FinancialOperation)
}

final class OperationService: OperationServiceProtocol {
    private let coreDataStack: CoreDataStackProtocol

    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }

    func fetchAllOperations() -> [FinancialOperation] {
        let request: NSFetchRequest<FinancialOperation> = NSFetchRequest(entityName: "FinancialOperation")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try coreDataStack.viewContext.fetch(request)
        } catch {
            print("Failed to fetch operations: \(error)")
            return []
        }
    }

    func fetchOperations(for todo: TodoItem) -> [FinancialOperation] {
        let request: NSFetchRequest<FinancialOperation> = NSFetchRequest(entityName: "FinancialOperation")
        request.predicate = NSPredicate(format: "todoItem == %@", todo)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try coreDataStack.viewContext.fetch(request)
        } catch {
            print("Failed to fetch operations for todo: \(error)")
            return []
        }
    }

    @discardableResult
    func createOperation(title: String, amount: NSDecimalNumber, date: Date, category: Category, todoItem: TodoItem?) -> FinancialOperation {
        let operation = FinancialOperation(context: coreDataStack.viewContext)
        operation.id = UUID()
        operation.title = title
        operation.amount = amount
        operation.date = date
        operation.category = category
        operation.todoItem = todoItem
        coreDataStack.saveContext()
        return operation
    }

    func updateOperation(_ operation: FinancialOperation, title: String, amount: NSDecimalNumber, date: Date, category: Category, todoItem: TodoItem?) {
        operation.title = title
        operation.amount = amount
        operation.date = date
        operation.category = category
        operation.todoItem = todoItem
        coreDataStack.saveContext()
    }

    func deleteOperation(_ operation: FinancialOperation) {
        coreDataStack.viewContext.delete(operation)
        coreDataStack.saveContext()
    }
}
