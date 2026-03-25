# CashTodo

iOS-приложение, совмещающее трекер задач и учёт финансов. Задачи и финансовые операции связаны между собой: привязка операции к задаче автоматически уменьшает оставшуюся сумму задачи.

## Основные понятия

### TodoItem (Задача)
Задача с названием, описанием и опциональной ценой. При наличии цены задача считается «долгом» до момента выполнения. Выполнение задачи с ценой автоматически создаёт финансовую операцию на полную сумму.

| Поле | Тип | Описание |
|------|-----|----------|
| `id` | UUID | Уникальный идентификатор |
| `title` | String | Название задачи |
| `descriptionText` | String? | Описание |
| `isCompleted` | Bool | Статус выполнения |
| `createdAt` | Date | Дата создания |
| `price` | Decimal? | Стоимость (для расчёта долга) |
| `operations` | [FinancialOperation] | Связанные операции |

### FinancialOperation (Финансовая операция)
Запись о трате с категорией и опциональной привязкой к задаче. При привязке к задаче сумма операции вычитается из цены задачи (минимум 0). При удалении или отвязке операции — цена задачи восстанавливается.

| Поле | Тип | Описание |
|------|-----|----------|
| `id` | UUID | Уникальный идентификатор |
| `title` | String | Название операции |
| `amount` | Decimal | Сумма |
| `date` | Date | Дата операции |
| `category` | Category | Категория |
| `todoItem` | TodoItem? | Связанная задача |

### Category (Категория)
Категория трат с иконкой (SF Symbol). При первом запуске создаётся 7 категорий по умолчанию. Нельзя удалить категорию, если к ней привязаны операции.

Категории по умолчанию: Еда, Транспорт, Покупки, Развлечения, Счета, Здоровье, Прочее.

### Долг
Сумма цен всех незавершённых задач, у которых указана цена. Отображается в секции «Долги» на экране финансов.

## Экраны

### Задачи (TodoList)
- Список всех задач с чекбоксами, ценами и индикаторами привязанных операций
- Тап по чекбоксу — выполнение задачи (при наличии цены автоматически создаётся операция)
- Свайп влево — удаление, toggle выполнения
- Кнопка «+» — создание новой задачи (модальный экран)

### Детали задачи (TodoDetail)
- Просмотр и редактирование названия, описания, цены
- Список связанных финансовых операций
- Режим просмотра / редактирования с переключением
- Удаление задачи с подтверждением

### Финансы (OperationList)
- Секция «Долги» — незавершённые задачи с ценой и общая сумма
- Операции, сгруппированные по категориям
- Фильтрация по дате: Все / Сегодня / Неделя / Месяц / Произвольный период
- Свайп влево — удаление операции
- Кнопка «+» — создание новой операции

### Редактирование операции (OperationEdit)
- Название, сумма (валидация: только цифры, макс. 2 знака после точки), дата
- Выбор категории (UIPickerView)
- Опциональная привязка к задаче

## Архитектура

### VIPER
Каждый модуль (экран) состоит из 6 компонентов:

| Компонент | Файл | Ответственность |
|-----------|------|-----------------|
| **Protocols** | `*Protocols.swift` | Интерфейсы + ViewModel'ы |
| **Assembly** | `*Assembly.swift` | Сборка и DI (static `build()`) |
| **View** | `*ViewController.swift` | UI, отображение данных |
| **Interactor** | `*Interactor.swift` | Бизнес-логика |
| **Presenter** | `*Presenter.swift` | Подготовка данных для View |
| **Router** | `*Router.swift` | Навигация |

Протоколы:
- `BusinessLogic` — вход в Interactor
- `DataStore` — хранение данных Interactor
- `PresentationLogic` — вход в Presenter
- `DisplayLogic` — вход во View (из Presenter)
- `RoutingLogic` — вход в Router

### Навигация
```
UITabBarController
├── Tab "Задачи" → UINavigationController
│     └── TodoListVC
│           ├── [tap] → push TodoDetailVC
│           └── [+]   → present TodoDetailVC (создание)
│
└── Tab "Финансы" → UINavigationController
      └── OperationListVC
            ├── [tap операцию]         → present OperationEditVC
            ├── [tap задачу в долгах]  → push TodoDetailVC
            └── [+]                    → present OperationEditVC (создание)
```

### Сервисный слой
Протоколы сервисов абстрагируют CoreData:

- **TodoServiceProtocol** — CRUD задач, toggle выполнения, выборка незавершённых с ценой
- **OperationServiceProtocol** — CRUD операций, автоматическая корректировка цены задачи при привязке/отвязке/удалении
- **CategoryServiceProtocol** — CRUD категорий, seed по умолчанию, защита от удаления с операциями

DI: сервисы создаются в Assembly и передаются в Interactor через конструктор.

## Стек технологий

| Технология | Детали |
|-----------|--------|
| Swift | 5.0 (Swift 6 concurrency: `@MainActor` по умолчанию) |
| UIKit | Программный UI без Storyboard (кроме LaunchScreen) |
| CoreData | Программная модель (без .xcdatamodeld) |
| Архитектура | VIPER |
| Layout | `UIView+Pin` extension для Auto Layout |
| Локализация | English (base) + Russian через `Localizable.strings` |
| Тесты | XCTest, 30 unit-тестов (in-memory CoreData stack) |
| Иконки | SF Symbols (без кастомных ресурсов) |

## Структура проекта

```
cashtodo/
├── App/                     — AppDelegate, SceneDelegate
├── Core/
│   ├── Constants/           — Constants.swift, L10n.swift (локализация)
│   ├── CoreData/            — CoreDataStack, CoreDataModelSetup
│   ├── Extensions/          — UIView+Pin, DecimalTextFieldDelegate
│   └── Protocols/           — CoreDataStackProtocol
├── Models/                  — NSManagedObject-подклассы (TodoItem, FinancialOperation, Category)
├── Services/                — TodoService, OperationService, CategoryService
├── Modules/
│   ├── TabBar/              — TabBarAssembly (2 вкладки)
│   ├── TodoList/            — Список задач (7 файлов)
│   ├── TodoDetail/          — Просмотр/редактирование задачи (6 файлов)
│   ├── OperationList/       — Список операций + долги + фильтры (8 файлов)
│   └── OperationEdit/       — Создание/редактирование операции (6 файлов)
└── Resources/               — Assets, LaunchScreen, Localizable.strings (en, ru)

cashtodoTests/
└── Services/                — 30 unit-тестов для всех сервисов
```

```bash
# Сборка
xcodebuild -scheme cashtodo -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Тесты
xcodebuild -scheme cashtodo -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## Запуск

Открыть `cashtodo.xcodeproj` в Xcode, выбрать симулятор, **Cmd+R**.
