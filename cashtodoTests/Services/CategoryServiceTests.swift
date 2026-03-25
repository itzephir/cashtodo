import XCTest
@testable import cashtodo

final class CategoryServiceTests: XCTestCase {

    private var stack: CoreDataStack!
    private var sut: CategoryService!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack(inMemory: true)
        sut = CategoryService(coreDataStack: stack)
    }

    override func tearDown() {
        sut = nil
        stack = nil
        super.tearDown()
    }

    // MARK: - Seed

    func testSeedDefaultCategories() {
        sut.seedDefaultCategories()

        let categories = sut.fetchAllCategories()
        XCTAssertEqual(categories.count, Constants.DefaultCategory.items.count)
    }

    func testSeedDoesNotDuplicateOnSecondCall() {
        sut.seedDefaultCategories()
        sut.seedDefaultCategories()

        let categories = sut.fetchAllCategories()
        XCTAssertEqual(categories.count, Constants.DefaultCategory.items.count)
    }

    // MARK: - Create

    func testCreateCategory() {
        let category = sut.createCategory(name: "Custom", iconName: "star")

        XCTAssertEqual(category.name, "Custom")
        XCTAssertEqual(category.iconName, "star")
        XCTAssertNotNil(category.id)
    }

    // MARK: - Fetch

    func testFetchAllCategoriesSortedByName() {
        sut.createCategory(name: "Zebra", iconName: "tag")
        sut.createCategory(name: "Alpha", iconName: "tag")

        let categories = sut.fetchAllCategories()
        XCTAssertEqual(categories.first?.name, "Alpha")
        XCTAssertEqual(categories.last?.name, "Zebra")
    }

    // MARK: - Delete

    func testDeleteCategoryWithoutOperations() {
        let category = sut.createCategory(name: "Empty", iconName: "tag")

        XCTAssertNoThrow(try sut.deleteCategory(category))
        XCTAssertEqual(sut.fetchAllCategories().count, 0)
    }

    func testDeleteCategoryWithOperationsThrows() {
        let category = sut.createCategory(name: "HasOps", iconName: "tag")

        // Create an operation directly linked to this category
        let op = FinancialOperation(context: stack.viewContext)
        op.id = UUID()
        op.title = "Test Op"
        op.amount = NSDecimalNumber(value: 10)
        op.date = Date()
        op.category = category
        stack.saveContext()

        do {
            try sut.deleteCategory(category)
            XCTFail("Expected CategoryError.hasOperations to be thrown")
        } catch {
            XCTAssertTrue(error is CategoryError)
        }
    }
}
