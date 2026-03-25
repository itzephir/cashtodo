import CoreData

protocol TodoServiceProtocol {
    func fetchAllTodos() -> [TodoItem]
    func fetchTodo(by id: UUID) -> TodoItem?
    func fetchIncompleteTodosWithPrice() -> [TodoItem]
    @discardableResult
    func createTodo(title: String, descriptionText: String?, price: NSDecimalNumber?) -> TodoItem
    func updateTodo(_ todo: TodoItem, title: String, descriptionText: String?, price: NSDecimalNumber?)
    func deleteTodo(_ todo: TodoItem)
    func toggleCompletion(_ todo: TodoItem)
}

final class TodoService: TodoServiceProtocol {
    private let coreDataStack: CoreDataStackProtocol

    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }

    func fetchAllTodos() -> [TodoItem] {
        let request: NSFetchRequest<TodoItem> = NSFetchRequest(entityName: "TodoItem")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            return try coreDataStack.viewContext.fetch(request)
        } catch {
            print("Failed to fetch todos: \(error)")
            return []
        }
    }

    func fetchTodo(by id: UUID) -> TodoItem? {
        let request: NSFetchRequest<TodoItem> = NSFetchRequest(entityName: "TodoItem")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            return try coreDataStack.viewContext.fetch(request).first
        } catch {
            print("Failed to fetch todo by id: \(error)")
            return nil
        }
    }

    func fetchIncompleteTodosWithPrice() -> [TodoItem] {
        let request: NSFetchRequest<TodoItem> = NSFetchRequest(entityName: "TodoItem")
        request.predicate = NSPredicate(format: "isCompleted == NO AND price != nil")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            return try coreDataStack.viewContext.fetch(request)
        } catch {
            print("Failed to fetch incomplete todos with price: \(error)")
            return []
        }
    }

    @discardableResult
    func createTodo(title: String, descriptionText: String?, price: NSDecimalNumber?) -> TodoItem {
        let todo = TodoItem(context: coreDataStack.viewContext)
        todo.id = UUID()
        todo.title = title
        todo.descriptionText = descriptionText
        todo.price = price
        todo.isCompleted = false
        todo.createdAt = Date()
        coreDataStack.saveContext()
        return todo
    }

    func updateTodo(_ todo: TodoItem, title: String, descriptionText: String?, price: NSDecimalNumber?) {
        todo.title = title
        todo.descriptionText = descriptionText
        todo.price = price
        coreDataStack.saveContext()
    }

    func deleteTodo(_ todo: TodoItem) {
        coreDataStack.viewContext.delete(todo)
        coreDataStack.saveContext()
    }

    func toggleCompletion(_ todo: TodoItem) {
        todo.isCompleted.toggle()
        coreDataStack.saveContext()
    }
}
