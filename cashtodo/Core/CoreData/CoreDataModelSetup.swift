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

        let operationEntity = NSEntityDescription()
        operationEntity.name = "FinancialOperation"
        operationEntity.managedObjectClassName = "FinancialOperation"

        let operationId = NSAttributeDescription()
        operationId.name = "id"
        operationId.attributeType = .UUIDAttributeType
        operationId.isOptional = false

        let operationTitle = NSAttributeDescription()
        operationTitle.name = "title"
        operationTitle.attributeType = .stringAttributeType
        operationTitle.isOptional = false

        let operationAmount = NSAttributeDescription()
        operationAmount.name = "amount"
        operationAmount.attributeType = .decimalAttributeType
        operationAmount.isOptional = false

        let operationDate = NSAttributeDescription()
        operationDate.name = "date"
        operationDate.attributeType = .dateAttributeType
        operationDate.isOptional = false

        // MARK: - Category Entity

        let categoryEntity = NSEntityDescription()
        categoryEntity.name = "Category"
        categoryEntity.managedObjectClassName = "Category"

        let categoryId = NSAttributeDescription()
        categoryId.name = "id"
        categoryId.attributeType = .UUIDAttributeType
        categoryId.isOptional = false

        let categoryName = NSAttributeDescription()
        categoryName.name = "name"
        categoryName.attributeType = .stringAttributeType
        categoryName.isOptional = false

        let categoryIconName = NSAttributeDescription()
        categoryIconName.name = "iconName"
        categoryIconName.attributeType = .stringAttributeType
        categoryIconName.isOptional = false
        categoryIconName.defaultValue = "tag"

        // MARK: - Relationships

        // TodoItem.operations <-->> FinancialOperation.todoItem
        let todoOperationsRelation = NSRelationshipDescription()
        todoOperationsRelation.name = "operations"
        todoOperationsRelation.destinationEntity = operationEntity
        todoOperationsRelation.minCount = 0
        todoOperationsRelation.maxCount = 0 // to-many
        todoOperationsRelation.deleteRule = .nullifyDeleteRule
        todoOperationsRelation.isOptional = true

        let operationTodoItemRelation = NSRelationshipDescription()
        operationTodoItemRelation.name = "todoItem"
        operationTodoItemRelation.destinationEntity = todoItemEntity
        operationTodoItemRelation.minCount = 0
        operationTodoItemRelation.maxCount = 1 // to-one
        operationTodoItemRelation.deleteRule = .nullifyDeleteRule
        operationTodoItemRelation.isOptional = true

        todoOperationsRelation.inverseRelationship = operationTodoItemRelation
        operationTodoItemRelation.inverseRelationship = todoOperationsRelation

        // FinancialOperation.category <--> Category.operations
        let operationCategoryRelation = NSRelationshipDescription()
        operationCategoryRelation.name = "category"
        operationCategoryRelation.destinationEntity = categoryEntity
        operationCategoryRelation.minCount = 0
        operationCategoryRelation.maxCount = 1 // to-one
        operationCategoryRelation.deleteRule = .nullifyDeleteRule
        operationCategoryRelation.isOptional = true

        let categoryOperationsRelation = NSRelationshipDescription()
        categoryOperationsRelation.name = "operations"
        categoryOperationsRelation.destinationEntity = operationEntity
        categoryOperationsRelation.minCount = 0
        categoryOperationsRelation.maxCount = 0 // to-many
        categoryOperationsRelation.deleteRule = .denyDeleteRule
        categoryOperationsRelation.isOptional = true

        operationCategoryRelation.inverseRelationship = categoryOperationsRelation
        categoryOperationsRelation.inverseRelationship = operationCategoryRelation

        // MARK: - Assign properties to entities

        todoItemEntity.properties = [
            todoId, todoTitle, todoDescriptionText,
            todoIsCompleted, todoCreatedAt, todoPrice,
            todoOperationsRelation,
        ]

        operationEntity.properties = [
            operationId, operationTitle, operationAmount, operationDate,
            operationCategoryRelation, operationTodoItemRelation,
        ]

        categoryEntity.properties = [
            categoryId, categoryName, categoryIconName,
            categoryOperationsRelation,
        ]

        model.entities = [todoItemEntity, operationEntity, categoryEntity]

        return model
    }
}
