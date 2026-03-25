import UIKit

enum TabBarAssembly {
    static func build() -> UITabBarController {
        let tabBarController = UITabBarController()

        let todoNav = UINavigationController(
            rootViewController: TodoListAssembly.build()
        )
        todoNav.tabBarItem = UITabBarItem(
            title: "Задачи",
            image: UIImage(systemName: Constants.Icon.tabTodos),
            tag: 0
        )
        todoNav.navigationBar.prefersLargeTitles = true

        let financeNav = UINavigationController(
            rootViewController: OperationListAssembly.build()
        )
        financeNav.tabBarItem = UITabBarItem(
            title: "Финансы",
            image: UIImage(systemName: Constants.Icon.tabFinance),
            tag: 1
        )
        financeNav.navigationBar.prefersLargeTitles = true

        tabBarController.viewControllers = [todoNav, financeNav]
        return tabBarController
    }
}
