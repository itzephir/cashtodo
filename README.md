# CashTodo

iOS-приложение для управления задачами и учёта финансов.

## Основные понятия

- **TodoItem (Задача)** — задача с названием, описанием и опциональной ценой. Может быть связана с финансовыми операциями.
- **FinancialOperation (Финансовая операция)** — запись о трате: название, сумма, дата, категория. Может быть привязана к задаче.
- **Category (Категория)** — категория трат (Еда, Транспорт, Покупки и т.д.). Иконки — SF Symbols.
- **Долг** — сумма цен незавершённых задач. Отображается в секции «Долг» на экране финансов.

## Экраны

- **Задачи** — список задач, создание, просмотр/редактирование, удаление
- **Финансы** — список операций по категориям, секция «Долг», создание/редактирование операций

## Стек технологий

- Swift, UIKit (programmatic), CoreData
- Архитектура: VIPER
- iOS 26.2+

## Структура проекта

```
cashtodo/
├── App/          — AppDelegate, SceneDelegate
├── Core/         — константы, расширения, протоколы, CoreData
├── Models/       — NSManagedObject-подклассы
├── Services/     — TodoService, OperationService, CategoryService
├── Modules/      — VIPER-модули (TabBar, TodoList, TodoDetail, OperationList, OperationEdit)
└── Resources/    — Assets.xcassets, LaunchScreen.storyboard
```

## Запуск

Открыть `cashtodo.xcodeproj` в Xcode, выбрать симулятор, **Cmd+R**.
