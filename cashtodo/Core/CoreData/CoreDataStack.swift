import CoreData

final class CoreDataStack: CoreDataStackProtocol {
    nonisolated static let shared = CoreDataStack()

    private let container: NSPersistentContainer

    nonisolated init(inMemory: Bool = false) {
        let model = CoreDataModelSetup.createModel()
        container = NSPersistentContainer(name: "CashTodo", managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    nonisolated var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    nonisolated func saveContext() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
