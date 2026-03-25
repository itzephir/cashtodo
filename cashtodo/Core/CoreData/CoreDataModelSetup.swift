import CoreData

enum CoreDataModelSetup: Sendable {
    nonisolated static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // MARK: - TodoItem Entity

        let todoItemEntity = NSEntityDescription()
        todoItemEntity.name = "TodoItem"
        todoItemEntity.managedObjectClassName = "TodoItem"

        let todoId = NSAttributeDescription()
        todoId.name = "id"
        todoId.attributeType = .UUIDAttributeType
        todoId.isOptional = false

        let todoTitle = NSAttributeDescription()
        todoTitle.name = "title"
        todoTitle.attributeType = .stringAttributeType
        todoTitle.isOptional = false

        let todoDescriptionText = NSAttributeDescription()
        todoDescriptionText.name = "descriptionText"
        todoDescriptionText.attributeType = .stringAttributeType
        todoDescriptionText.isOptional = true

        let todoIsCompleted = NSAttributeDescription()
        todoIsCompleted.name = "isCompleted"
        todoIsCompleted.attributeType = .booleanAttributeType
        todoIsCompleted.isOptional = false
        todoIsCompleted.defaultValue = false

        let todoCreatedAt = NSAttributeDescription()
        todoCreatedAt.name = "createdAt"
        todoCreatedAt.attributeType = .dateAttributeType
        todoCreatedAt.isOptional = false

        let todoPrice = NSAttributeDescription()
        todoPrice.name = "price"
        todoPrice.attributeType = .decimalAttributeType
        todoPrice.isOptional = true

        // MARK: - FinancialOperation Entity

        let financialOperationEntity = NSEntityDescription()
        financialOperationEntity.name = "FinancialOperation"
        financialOperationEntity.managedObjectClassName = "FinancialOperation"

        let opId = NSAttributeDescription()
        opId.name = "id"
        opId.attributeType = .UUIDAttributeType
        opId.isOptional = false

        let opTitle = NSAttributeDescription()
        opTitle.name = "title"
        opTitle.attributeType = .stringAttributeType
        opTitle.isOptional = false

        let opAmount = NSAttributeDescription()
        opAmount.name = "amount"
        opAmount.attributeType = .decimalAttributeType
        opAmount.isOptional = false

        let opDate = NSAttributeDescription()
        opDate.name = "date"
        opDate.attributeType = .dateAttributeType
        opDate.isOptional = false

        // MARK: - Category Entity

        let categoryEntity = NSEntityDescription()
        categoryEntity.name = "Category"
        categoryEntity.managedObjectClassName = "Category"

        let catId = NSAttributeDescription()
        catId.name = "id"
        catId.attributeType = .UUIDAttributeType
        catId.isOptional = false

        let catName = NSAttributeDescription()
        catName.name = "name"
        catName.attributeType = .stringAttributeType
        catName.isOptional = false

        let catIconName = NSAttributeDescription()
        catIconName.name = "iconName"
        catIconName.attributeType = .stringAttributeType
        catIconName.isOptional = false
        catIconName.defaultValue = "tag"

        // MARK: - Relationships

        // TodoItem.operations <-->> FinancialOperation.todoItem
        let todoOperationsRel = NSRelationshipDescription()
        todoOperationsRel.name = "operations"
        todoOperationsRel.destinationEntity = financialOperationEntity
        todoOperationsRel.minCount = 0
        todoOperationsRel.maxCount = 0 // to-many
        todoOperationsRel.deleteRule = .nullifyDeleteRule
        todoOperationsRel.isOptional = true

        let opTodoItemRel = NSRelationshipDescription()
        opTodoItemRel.name = "todoItem"
        opTodoItemRel.destinationEntity = todoItemEntity
        opTodoItemRel.minCount = 0
        opTodoItemRel.maxCount = 1 // to-one
        opTodoItemRel.deleteRule = .nullifyDeleteRule
        opTodoItemRel.isOptional = true

        todoOperationsRel.inverseRelationship = opTodoItemRel
        opTodoItemRel.inverseRelationship = todoOperationsRel

        // FinancialOperation.category <--> Category.operations
        let opCategoryRel = NSRelationshipDescription()
        opCategoryRel.name = "category"
        opCategoryRel.destinationEntity = categoryEntity
        opCategoryRel.minCount = 0
        opCategoryRel.maxCount = 1 // to-one
        opCategoryRel.deleteRule = .nullifyDeleteRule
        opCategoryRel.isOptional = true

        let catOperationsRel = NSRelationshipDescription()
        catOperationsRel.name = "operations"
        catOperationsRel.destinationEntity = financialOperationEntity
        catOperationsRel.minCount = 0
        catOperationsRel.maxCount = 0 // to-many
        catOperationsRel.deleteRule = .denyDeleteRule
        catOperationsRel.isOptional = true

        opCategoryRel.inverseRelationship = catOperationsRel
        catOperationsRel.inverseRelationship = opCategoryRel

        // MARK: - Assign properties to entities

        todoItemEntity.properties = [
            todoId, todoTitle, todoDescriptionText,
            todoIsCompleted, todoCreatedAt, todoPrice,
            todoOperationsRel,
        ]

        financialOperationEntity.properties = [
            opId, opTitle, opAmount, opDate,
            opCategoryRel, opTodoItemRel,
        ]

        categoryEntity.properties = [
            catId, catName, catIconName,
            catOperationsRel,
        ]

        model.entities = [todoItemEntity, financialOperationEntity, categoryEntity]

        return model
    }
}
