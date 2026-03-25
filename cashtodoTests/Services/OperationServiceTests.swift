import XCTest
@testable import cashtodo

final class OperationServiceTests: XCTestCase {

    private var stack: CoreDataStack!
    private var sut: OperationService!
    private var categoryService: CategoryService!
    private var todoService: TodoService!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack(inMemory: true)
        sut = OperationService(coreDataStack: stack)
        categoryService = CategoryService(coreDataStack: stack)
        todoService = TodoService(coreDataStack: stack)
    }

    override func tearDown() {
        sut = nil
        categoryService = nil
        todoService = nil
        stack = nil
        super.tearDown()
    }

    private func makeCategory() -> cashtodo.Category {
        categoryService.createCategory(name: "Test", iconName: "tag")
    }

    // MARK: - Create

    func testCreateOperation() {
        let category = makeCategory()
        let operation = sut.createOperation(
            title: "Groceries",
            amount: NSDecimalNumber(value: 150.50),
            date: Date(),
            category: category,
            todoItem: nil
        )

        XCTAssertEqual(operation.title, "Groceries")
        XCTAssertEqual(operation.amount, NSDecimalNumber(value: 150.50))
        XCTAssertEqual(operation.category?.id, category.id)
        XCTAssertNil(operation.todoItem)
    }

    func testCreateOperationWithLinkedTodo() {
        let category = makeCategory()
        let todo = todoService.createTodo(title: "Buy supplies", descriptionText: nil, price: nil)

        let operation = sut.createOperation(
            title: "Supplies",
            amount: NSDecimalNumber(value: 50),
            date: Date(),
            category: category,
            todoItem: todo
        )

        XCTAssertEqual(operation.todoItem?.id, todo.id)
    }

    // MARK: - Fetch

    func testFetchAllOperations() {
        let category = makeCategory()
        sut.createOperation(title: "Op1", amount: NSDecimalNumber(value: 10), date: Date(), category: category, todoItem: nil)
        sut.createOperation(title: "Op2", amount: NSDecimalNumber(value: 20), date: Date(), category: category, todoItem: nil)

        let operations = sut.fetchAllOperations()
        XCTAssertEqual(operations.count, 2)
    }

    func testFetchOperationsForTodo() {
        let category = makeCategory()
        let todo = todoService.createTodo(title: "Task", descriptionText: nil, price: nil)

        sut.createOperation(title: "Linked", amount: NSDecimalNumber(value: 10), date: Date(), category: category, todoItem: todo)
        sut.createOperation(title: "Unlinked", amount: NSDecimalNumber(value: 20), date: Date(), category: category, todoItem: nil)

        let operations = sut.fetchOperations(for: todo)
        XCTAssertEqual(operations.count, 1)
        XCTAssertEqual(operations.first?.title, "Linked")
    }

    // MARK: - Update

    func testUpdateOperation() {
        let category1 = makeCategory()
        let category2 = categoryService.createCategory(name: "Other", iconName: "star")
        let operation = sut.createOperation(title: "Old", amount: NSDecimalNumber(value: 10), date: Date(), category: category1, todoItem: nil)

        sut.updateOperation(operation, title: "New", amount: NSDecimalNumber(value: 99), date: Date(), category: category2, todoItem: nil)

        XCTAssertEqual(operation.title, "New")
        XCTAssertEqual(operation.amount, NSDecimalNumber(value: 99))
        XCTAssertEqual(operation.category?.id, category2.id)
    }

    // MARK: - Price adjustment on link

    func testCreateOperationReducesTodoPrice() {
        let category = makeCategory()
        let todo = todoService.createTodo(title: "Buy food", descriptionText: nil, price: NSDecimalNumber(value: 100))

        sut.createOperation(title: "Carrots", amount: NSDecimalNumber(value: 40), date: Date(), category: category, todoItem: todo)

        XCTAssertEqual(todo.price, NSDecimalNumber(value: 60))
    }

    func testCreateMultipleOperationsReducesTodoPriceProgressively() {
        let category = makeCategory()
        let todo = todoService.createTodo(title: "Buy food", descriptionText: nil, price: NSDecimalNumber(value: 100))

        sut.createOperation(title: "Carrots", amount: NSDecimalNumber(value: 40), date: Date(), category: category, todoItem: todo)
        sut.createOperation(title: "Bread", amount: NSDecimalNumber(value: 30), date: Date(), category: category, todoItem: todo)

        XCTAssertEqual(todo.price, NSDecimalNumber(value: 30))
    }

    func testCreateOperationClampsToZero() {
        let category = makeCategory()
        let todo = todoService.createTodo(title: "Small task", descriptionText: nil, price: NSDecimalNumber(value: 20))

        sut.createOperation(title: "Overspend", amount: NSDecimalNumber(value: 50), date: Date(), category: category, todoItem: todo)

        XCTAssertEqual(todo.price, NSDecimalNumber.zero)
    }

    func testCreateOperationWithoutTodoDoesNotAffectAnything() {
        let category = makeCategory()
        let todo = todoService.createTodo(title: "Unrelated", descriptionText: nil, price: NSDecimalNumber(value: 100))

        sut.createOperation(title: "Standalone", amount: NSDecimalNumber(value: 40), date: Date(), category: category, todoItem: nil)

        XCTAssertEqual(todo.price, NSDecimalNumber(value: 100))
    }

    func testCreateOperationWithNilPriceTodoDoesNotCrash() {
        let category = makeCategory()
        let todo = todoService.createTodo(title: "No price", descriptionText: nil, price: nil)

        sut.createOperation(title: "Op", amount: NSDecimalNumber(value: 10), date: Date(), category: category, todoItem: todo)

        XCTAssertNil(todo.price)
    }

    func testDeleteOperationRestoresTodoPrice() {
        let category = makeCategory()
        let todo = todoService.createTodo(title: "Buy food", descriptionText: nil, price: NSDecimalNumber(value: 100))

        let operation = sut.createOperation(title: "Carrots", amount: NSDecimalNumber(value: 40), date: Date(), category: category, todoItem: todo)
        XCTAssertEqual(todo.price, NSDecimalNumber(value: 60))

        sut.deleteOperation(operation)
        XCTAssertEqual(todo.price, NSDecimalNumber(value: 100))
    }

    func testUpdateOperationAdjustsPriceOnAmountChange() {
        let category = makeCategory()
        let todo = todoService.createTodo(title: "Buy food", descriptionText: nil, price: NSDecimalNumber(value: 100))

        let operation = sut.createOperation(title: "Carrots", amount: NSDecimalNumber(value: 40), date: Date(), category: category, todoItem: todo)
        XCTAssertEqual(todo.price, NSDecimalNumber(value: 60))

        sut.updateOperation(operation, title: "Carrots", amount: NSDecimalNumber(value: 70), date: Date(), category: category, todoItem: todo)
        XCTAssertEqual(todo.price, NSDecimalNumber(value: 30))
    }

    func testUpdateOperationRelinkAdjustsBothTodos() {
        let category = makeCategory()
        let todo1 = todoService.createTodo(title: "Task 1", descriptionText: nil, price: NSDecimalNumber(value: 100))
        let todo2 = todoService.createTodo(title: "Task 2", descriptionText: nil, price: NSDecimalNumber(value: 200))

        let operation = sut.createOperation(title: "Op", amount: NSDecimalNumber(value: 30), date: Date(), category: category, todoItem: todo1)
        XCTAssertEqual(todo1.price, NSDecimalNumber(value: 70))

        sut.updateOperation(operation, title: "Op", amount: NSDecimalNumber(value: 30), date: Date(), category: category, todoItem: todo2)
        XCTAssertEqual(todo1.price, NSDecimalNumber(value: 100))
        XCTAssertEqual(todo2.price, NSDecimalNumber(value: 170))
    }

    func testUpdateOperationUnlinkRestoresPrice() {
        let category = makeCategory()
        let todo = todoService.createTodo(title: "Task", descriptionText: nil, price: NSDecimalNumber(value: 100))

        let operation = sut.createOperation(title: "Op", amount: NSDecimalNumber(value: 25), date: Date(), category: category, todoItem: todo)
        XCTAssertEqual(todo.price, NSDecimalNumber(value: 75))

        sut.updateOperation(operation, title: "Op", amount: NSDecimalNumber(value: 25), date: Date(), category: category, todoItem: nil)
        XCTAssertEqual(todo.price, NSDecimalNumber(value: 100))
    }

    // MARK: - Delete

    func testDeleteOperation() {
        let category = makeCategory()
        let operation = sut.createOperation(title: "Delete", amount: NSDecimalNumber(value: 10), date: Date(), category: category, todoItem: nil)
        let id = operation.id

        sut.deleteOperation(operation)

        let all = sut.fetchAllOperations()
        XCTAssertFalse(all.contains(where: { $0.id == id }))
    }
}
