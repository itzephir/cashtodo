import XCTest
@testable import cashtodo

final class TodoServiceTests: XCTestCase {

    private var stack: CoreDataStack!
    private var sut: TodoService!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack(inMemory: true)
        sut = TodoService(coreDataStack: stack)
    }

    override func tearDown() {
        sut = nil
        stack = nil
        super.tearDown()
    }

    // MARK: - Create

    func testCreateTodo() {
        let todo = sut.createTodo(title: "Test", descriptionText: "Desc", price: NSDecimalNumber(value: 100))

        XCTAssertEqual(todo.title, "Test")
        XCTAssertEqual(todo.descriptionText, "Desc")
        XCTAssertEqual(todo.price, NSDecimalNumber(value: 100))
        XCTAssertFalse(todo.isCompleted)
        XCTAssertNotNil(todo.id)
        XCTAssertNotNil(todo.createdAt)
    }

    func testCreateTodoWithoutPrice() {
        let todo = sut.createTodo(title: "No Price", descriptionText: nil, price: nil)

        XCTAssertEqual(todo.title, "No Price")
        XCTAssertNil(todo.descriptionText)
        XCTAssertNil(todo.price)
    }

    // MARK: - Fetch

    func testFetchAllTodos() {
        sut.createTodo(title: "First", descriptionText: nil, price: nil)
        sut.createTodo(title: "Second", descriptionText: nil, price: nil)

        let todos = sut.fetchAllTodos()
        XCTAssertEqual(todos.count, 2)
    }

    func testFetchTodoById() {
        let created = sut.createTodo(title: "Find Me", descriptionText: nil, price: nil)
        let found = sut.fetchTodo(by: created.id)

        XCTAssertNotNil(found)
        XCTAssertEqual(found?.title, "Find Me")
    }

    func testFetchTodoByInvalidId() {
        let found = sut.fetchTodo(by: UUID())
        XCTAssertNil(found)
    }

    func testFetchIncompleteTodosWithPrice() {
        sut.createTodo(title: "Has Price", descriptionText: nil, price: NSDecimalNumber(value: 50))
        sut.createTodo(title: "No Price", descriptionText: nil, price: nil)

        let completedTodo = sut.createTodo(title: "Completed", descriptionText: nil, price: NSDecimalNumber(value: 30))
        sut.toggleCompletion(completedTodo)

        let result = sut.fetchIncompleteTodosWithPrice()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Has Price")
    }

    // MARK: - Update

    func testUpdateTodo() {
        let todo = sut.createTodo(title: "Old", descriptionText: "Old Desc", price: nil)
        sut.updateTodo(todo, title: "New", descriptionText: "New Desc", price: NSDecimalNumber(value: 200))

        let fetched = sut.fetchTodo(by: todo.id)
        XCTAssertEqual(fetched?.title, "New")
        XCTAssertEqual(fetched?.descriptionText, "New Desc")
        XCTAssertEqual(fetched?.price, NSDecimalNumber(value: 200))
    }

    // MARK: - Delete

    func testDeleteTodo() {
        let todo = sut.createTodo(title: "Delete Me", descriptionText: nil, price: nil)
        let id = todo.id
        sut.deleteTodo(todo)

        let fetched = sut.fetchTodo(by: id)
        XCTAssertNil(fetched)
    }

    // MARK: - Toggle

    func testToggleCompletion() {
        let todo = sut.createTodo(title: "Toggle", descriptionText: nil, price: nil)
        XCTAssertFalse(todo.isCompleted)

        sut.toggleCompletion(todo)
        XCTAssertTrue(todo.isCompleted)

        sut.toggleCompletion(todo)
        XCTAssertFalse(todo.isCompleted)
    }
}
