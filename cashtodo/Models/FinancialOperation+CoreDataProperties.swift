import CoreData
import Foundation

extension FinancialOperation {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<FinancialOperation> {
        NSFetchRequest<FinancialOperation>(entityName: "FinancialOperation")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var date: Date
    @NSManaged public var category: Category?
    @NSManaged public var todoItem: TodoItem?
}

extension FinancialOperation: @unchecked Sendable {}
