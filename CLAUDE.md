# CashTodo

iOS task tracker + finance tracker with bidirectional linking between tasks and operations.

## Tech Stack

- **Language:** Swift 5.0 (Swift 6 concurrency: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- **UI:** UIKit (programmatic, no storyboards except LaunchScreen)
- **Persistence:** CoreData (programmatic model via `CoreDataModelSetup`, no .xcdatamodeld)
- **Architecture:** VIPER
- **Layout:** `UIView+Pin.swift` extension for Auto Layout
- **Localization:** English (base) + Russian via `Localizable.strings`, accessed through `L10n` enum
- **Build:** Xcode 26.3, iOS 26.2 deployment target
- **Bundle ID:** `com.itzephir.cashtodo`
- **Project format:** `PBXFileSystemSynchronizedRootGroup` — files on disk auto-compile

## Architecture (VIPER)

Each module: `Protocols.swift`, `Assembly.swift`, `ViewController.swift`, `Interactor.swift`, `Presenter.swift`, `Router.swift`

Protocol naming: `BusinessLogic`, `DataStore`, `PresentationLogic`, `DisplayLogic`, `RoutingLogic`

DI: services passed through `Assembly.build()` → Interactor constructor.

## Modules

- **TabBar** — 2 tabs (Tasks, Finance)
- **TodoList** — task list with checkbox toggle, swipe-to-delete
- **TodoDetail** — view/edit task, linked operations section
- **OperationList** — operations grouped by category, debt section, date filter chips
- **OperationEdit** — create/edit operation with category and todo pickers

## CoreData Entities

- **TodoItem:** id, title, descriptionText?, isCompleted, createdAt, price? → operations (to-many)
- **FinancialOperation:** id, title, amount, date → category (to-one), todoItem? (to-one)
- **Category:** id, name, iconName → operations (to-many, deny delete)

## Key Business Rules

- Completing a todo with price → auto-creates FinancialOperation for the full amount
- Linking an operation to a todo → subtracts amount from todo.price (clamped to 0)
- Unlinking/deleting an operation → restores amount to todo.price
- Cannot delete a category that has operations

## Constants & Localization

- All UI constants in `Core/Constants/Constants.swift` (paddings, sizes, icons)
- All user-visible strings in `Core/Constants/L10n.swift` → `Localizable.strings` (en, ru)
- Currency formatting uses `Locale.current`

## Tests

30 unit tests in `cashtodoTests/Services/` using `CoreDataStack(inMemory: true)`:
- `TodoServiceTests` (9) — CRUD, toggle, fetch queries
- `OperationServiceTests` (15) — CRUD, price adjustment on link/unlink/delete
- `CategoryServiceTests` (6) — seed, CRUD, delete protection

## Commands

```bash
# Build
xcodebuild -scheme cashtodo -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Test
xcodebuild -scheme cashtodo -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```
