import CoreData
import Foundation

extension TodoItem {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<TodoItem> {
        NSFetchRequest<TodoItem>(entityName: "TodoItem")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var descriptionText: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var price: NSDecimalNumber?
    @NSManaged public var operations: NSSet?
}

// MARK: - Generated accessors for operations

extension TodoItem {
    @objc(addOperationsObject:)
    @NSManaged public func addToOperations(_ value: FinancialOperation)

    @objc(removeOperationsObject:)
    @NSManaged public func removeFromOperations(_ value: FinancialOperation)

    @objc(addOperations:)
    @NSManaged public func addToOperations(_ values: NSSet)

    @objc(removeOperations:)
    @NSManaged public func removeFromOperations(_ values: NSSet)
}

extension TodoItem: @unchecked Sendable {}
