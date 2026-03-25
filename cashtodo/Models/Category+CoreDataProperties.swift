import CoreData
import Foundation

extension Category {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Category> {
        NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var iconName: String
    @NSManaged public var operations: NSSet?
}

// MARK: - Generated accessors for operations

extension Category {
    @objc(addOperationsObject:)
    @NSManaged public func addToOperations(_ value: FinancialOperation)

    @objc(removeOperationsObject:)
    @NSManaged public func removeFromOperations(_ value: FinancialOperation)

    @objc(addOperations:)
    @NSManaged public func addToOperations(_ values: NSSet)

    @objc(removeOperations:)
    @NSManaged public func removeFromOperations(_ values: NSSet)
}

extension Category: @unchecked Sendable {}
