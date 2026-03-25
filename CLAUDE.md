# CashTodo

iOS task tracker + finance tracker.

## Tech Stack

- **Language:** Swift (Swift 6 concurrency: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- **UI:** UIKit (programmatic, no storyboards except LaunchScreen)
- **Persistence:** CoreData
- **Architecture:** VIPER
- **Build:** Xcode 26.3, iOS 26.2 deployment target
- **Bundle ID:** `com.itzephir.cashtodo`
- **Project uses PBXFileSystemSynchronizedRootGroup** — files on disk auto-compile, no need to add to Xcode project manually.

## Architecture

VIPER pattern for each module. Each module contains:

- `Protocols.swift` — module protocols
- `Assembly.swift` — enum with static `build()` method
- `ViewController.swift` — view layer
- `Interactor.swift` — business logic
- `Presenter.swift` — presentation logic
- `Router.swift` — navigation

### Protocol Naming

- `BusinessLogic` — interactor input
- `DataStore` — interactor data
- `PresentationLogic` — presenter input
- `DisplayLogic` — view input
- `RoutingLogic` — router input

### Dependency Injection

Services use protocol-first design with CoreData implementations. DI is done by passing services through `Assembly.build()` into Interactors.

## Project Structure

```
cashtodo/
├── App/          (AppDelegate, SceneDelegate)
├── Core/         (Constants, Extensions, Protocols, CoreData)
├── Models/       (NSManagedObject subclasses)
├── Services/     (TodoService, OperationService, CategoryService)
├── Modules/      (VIPER modules: TabBar, TodoList, TodoDetail, OperationList, OperationEdit)
└── Resources/    (Assets.xcassets, LaunchScreen.storyboard)
```

## CoreData Entities

- **TodoItem:** id, title, descriptionText, isCompleted, createdAt, price (optional Decimal)
- **FinancialOperation:** id, title, amount, date + relationships to Category and TodoItem
- **Category:** id, name, iconName (SF Symbol)

## Navigation

2-tab `UITabBarController`:

1. **Задачи** — task list
2. **Финансы** — financial operations list. Debt shown as top section.

## Layout

`UIView+Pin.swift` extension for Auto Layout constraints.

## Tests

`cashtodoTests` target. Services tested with in-memory CoreData stack.

## Commands

Build:
```bash
xcodebuild -scheme cashtodo -sdk iphonesimulator build
```

Test:
```bash
xcodebuild -scheme cashtodo -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' test
```
