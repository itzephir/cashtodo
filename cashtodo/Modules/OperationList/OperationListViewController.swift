import UIKit

final class OperationListViewController: UIViewController {

    // MARK: - VIPER

    var interactor: OperationListBusinessLogic?
    var router: OperationListRoutingLogic?

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Data

    private var debtHeader: DebtHeaderViewModel?
    private var debtItems: [DebtCellViewModel] = []
    private var operationSections: [(categoryName: String, categoryIcon: String, operations: [OperationListCellViewModel])] = []

    // MARK: - Constants

    private enum CellID {
        static let debt = "DebtCell"
        static let operation = "OperationListCell"
        static let debtHeader = "DebtHeaderCell"
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.loadData()
    }

    // MARK: - Configuration

    private func configureNavigationBar() {
        navigationItem.title = "Финансы"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.Icon.add),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DebtCell.self, forCellReuseIdentifier: CellID.debt)
        tableView.register(OperationListCell.self, forCellReuseIdentifier: CellID.operation)

        view.addSubview(tableView)
        tableView.pin(to: view)
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        router?.navigateToCreate()
    }

    // MARK: - Helpers

    private func operationId(at indexPath: IndexPath) -> UUID? {
        let sectionIndex = indexPath.section - 1
        guard sectionIndex >= 0, sectionIndex < operationSections.count else { return nil }
        let operations = operationSections[sectionIndex].operations
        guard indexPath.row < operations.count else { return nil }
        return operations[indexPath.row].id
    }
}

// MARK: - OperationListDisplayLogic

extension OperationListViewController: OperationListDisplayLogic {
    func displayDebtHeader(_ viewModel: DebtHeaderViewModel) {
        debtHeader = viewModel
        tableView.reloadData()
    }

    func displayDebtItems(_ viewModels: [DebtCellViewModel]) {
        debtItems = viewModels
        tableView.reloadData()
    }

    func displayOperationSections(
        _ sections: [(categoryName: String, categoryIcon: String, operations: [OperationListCellViewModel])]
    ) {
        operationSections = sections
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension OperationListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1 + operationSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return debtItems.count
        }
        return operationSections[section - 1].operations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CellID.debt,
                for: indexPath
            ) as? DebtCell else {
                return UITableViewCell()
            }
            cell.configure(with: debtItems[indexPath.row])
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellID.operation,
            for: indexPath
        ) as? OperationListCell else {
            return UITableViewCell()
        }
        let sectionIndex = indexPath.section - 1
        let viewModel = operationSections[sectionIndex].operations[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        if section == 0 {
            return debtHeader?.totalDebtText
        }
        let sec = operationSections[section - 1]
        return "\(sec.categoryIcon) \(sec.categoryName)"
    }
}

// MARK: - UITableViewDelegate

extension OperationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            let todoId = debtItems[indexPath.row].id
            router?.navigateToTodoDetail(todoId: todoId)
            return
        }

        if let id = operationId(at: indexPath) {
            router?.navigateToEdit(operationId: id)
        }
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard indexPath.section > 0 else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            self?.interactor?.deleteOperation(at: indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: Constants.Icon.delete)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        guard section > 0 else { return nil }

        let sec = operationSections[section - 1]

        let header = UIView()
        header.backgroundColor = .clear

        let iconView = UIImageView(image: UIImage(systemName: sec.categoryIcon))
        iconView.tintColor = .label
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = sec.categoryName
        label.font = .systemFont(ofSize: Constants.Font.title, weight: .semibold)

        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = Constants.UI.smallPadding
        stack.alignment = .center

        header.addSubview(stack)
        stack.pinLeft(to: header, Constants.UI.standardPadding)
        stack.pinCenterY(to: header)
        iconView.setWidth(20)
        iconView.setHeight(20)

        return header
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        if section == 0 {
            return debtItems.isEmpty ? .leastNonzeroMagnitude : Constants.UI.sectionHeaderHeight
        }
        return Constants.UI.sectionHeaderHeight
    }
}
