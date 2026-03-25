import UIKit

enum Constants {
    enum UI {
        static let standardPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let buttonHeight: CGFloat = 50
        static let cellHeight: CGFloat = 60
        static let sectionHeaderHeight: CGFloat = 44
        static let chipBarHeight: CGFloat = 48
        static let chipHeight: CGFloat = 32
    }

    enum Font {
        static let largeTitle: CGFloat = 28
        static let title: CGFloat = 17
        static let subtitle: CGFloat = 14
        static let caption: CGFloat = 12
        static let price: CGFloat = 16
    }

    enum Icon {
        static let tabTodos = "checklist"
        static let tabFinance = "creditcard"
        static let debtSection = "exclamationmark.triangle"
        static let add = "plus"
        static let completed = "checkmark.circle.fill"
        static let incomplete = "circle"
        static let delete = "trash"
        static let edit = "pencil"
        static let price = "dollarsign.circle"
        static let link = "link"
        static let emptyState = "tray"
    }

    enum DefaultCategory {
        static let items: [(name: String, icon: String)] = [
            ("Еда", "fork.knife"),
            ("Транспорт", "car"),
            ("Покупки", "bag"),
            ("Развлечения", "gamecontroller"),
            ("Счета", "doc.text"),
            ("Здоровье", "heart"),
            ("Прочее", "tag")
        ]
    }
}
