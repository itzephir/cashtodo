import CoreData

enum CategoryError: Error {
    case hasOperations
}

protocol CategoryServiceProtocol {
    func fetchAllCategories() -> [Category]
    @discardableResult
    func createCategory(name: String, iconName: String) -> Category
    func deleteCategory(_ category: Category) throws
    func seedDefaultCategories()
}

final class CategoryService: CategoryServiceProtocol {
    private let coreDataStack: CoreDataStackProtocol

    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }

    func fetchAllCategories() -> [Category] {
        let request: NSFetchRequest<Category> = NSFetchRequest(entityName: "Category")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            return try coreDataStack.viewContext.fetch(request)
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }

    @discardableResult
    func createCategory(name: String, iconName: String) -> Category {
        let category = Category(context: coreDataStack.viewContext)
        category.id = UUID()
        category.name = name
        category.iconName = iconName
        coreDataStack.saveContext()
        return category
    }

    func deleteCategory(_ category: Category) throws {
        let request: NSFetchRequest<FinancialOperation> = NSFetchRequest(entityName: "FinancialOperation")
        request.predicate = NSPredicate(format: "category == %@", category)
        let count = (try? coreDataStack.viewContext.count(for: request)) ?? 0
        if count > 0 {
            throw CategoryError.hasOperations
        }
        coreDataStack.viewContext.delete(category)
        coreDataStack.saveContext()
    }

    func seedDefaultCategories() {
        let request: NSFetchRequest<Category> = NSFetchRequest(entityName: "Category")
        let count = (try? coreDataStack.viewContext.count(for: request)) ?? 0
        guard count == 0 else { return }

        for item in Constants.DefaultCategory.items {
            let category = Category(context: coreDataStack.viewContext)
            category.id = UUID()
            category.name = item.name
            category.iconName = item.icon
        }
        coreDataStack.saveContext()
    }
}
