import CoreData

nonisolated protocol CoreDataStackProtocol {
    var viewContext: NSManagedObjectContext { get }
    func saveContext()
}
