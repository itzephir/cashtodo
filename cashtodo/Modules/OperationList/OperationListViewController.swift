import UIKit

final class OperationListViewController: UIViewController {

    // MARK: - VIPER

    var interactor: OperationListBusinessLogic?
    var router: OperationListRoutingLogic?

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private let chipScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: Constants.UI.standardPadding,
            bottom: 0,
            right: Constants.UI.standardPadding
        )
        return scrollView
    }()

    private let chipStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.UI.smallPadding
        stackView.alignment = .center
        return stackView
    }()

    private let dateRangeContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .secondarySystemBackground
        return view
    }()

    private let fromPicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()

    private let toPicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()

    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.buttonApply, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.Font.subtitle, weight: .semibold)
        return button
    }()

    // MARK: - Data

    private var debtHeader: DebtHeaderViewModel?
    private var debtItems: [DebtCellViewModel] = []
    private var operationSections: [(categoryName: String, categoryIcon: String, operations: [OperationListCellViewModel])] = []

    private var selectedFilter: DateFilter = .all
    private var chipButtons: [UIButton] = []

    // MARK: - Constants

    private enum CellID {
        static let debt = "DebtCell"
        static let operation = "OperationListCell"
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureTableView()
        buildTableHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.loadData()
    }

    // MARK: - Configuration

    private func configureNavigationBar() {
        navigationItem.title = L10n.financeTitle
        navigationItem.largeTitleDisplayMode = .always
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

    private func buildTableHeader() {
        // Chip scroll — fixed height, content scrolls horizontally
        chipScrollView.setHeight(Constants.UI.chipBarHeight)
        chipScrollView.addSubview(chipStackView)
        chipStackView.pinTop(to: chipScrollView.contentLayoutGuide.topAnchor)
        chipStackView.pinBottom(to: chipScrollView.contentLayoutGuide.bottomAnchor)
        chipStackView.pinLeft(to: chipScrollView.contentLayoutGuide.leadingAnchor)
        chipStackView.pinRight(to: chipScrollView.contentLayoutGuide.trailingAnchor)
        chipStackView.pinHeight(to: chipScrollView.frameLayoutGuide.heightAnchor)

        let filters: [DateFilter] = DateFilter.presets + [.custom(from: Date(), to: Date())]
        for filter in filters {
            let button = makeChipButton(title: filter.title, tag: chipButtons.count)
            chipStackView.addArrangedSubview(button)
            chipButtons.append(button)
        }
        updateChipSelection()

        // Date range pickers
        let fromLabel = UILabel()
        fromLabel.text = L10n.labelFrom
        fromLabel.font = .systemFont(ofSize: Constants.Font.caption, weight: .medium)
        fromLabel.textColor = .secondaryLabel

        let toLabel = UILabel()
        toLabel.text = L10n.labelTo
        toLabel.font = .systemFont(ofSize: Constants.Font.caption, weight: .medium)
        toLabel.textColor = .secondaryLabel

        let fromColumn = UIStackView(arrangedSubviews: [fromLabel, fromPicker])
        fromColumn.axis = .vertical
        fromColumn.spacing = 4
        fromColumn.alignment = .leading

        let toColumn = UIStackView(arrangedSubviews: [toLabel, toPicker])
        toColumn.axis = .vertical
        toColumn.spacing = 4
        toColumn.alignment = .leading

        let pickersRow = UIStackView(arrangedSubviews: [fromColumn, toColumn])
        pickersRow.axis = .horizontal
        pickersRow.distribution = .fillEqually
        pickersRow.spacing = Constants.UI.standardPadding

        applyButton.setHeight(Constants.UI.smallButtonHeight)
        applyButton.layer.cornerRadius = Constants.UI.smallCornerRadius
        applyButton.backgroundColor = .systemBlue
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.addTarget(self, action: #selector(applyDateRange), for: .touchUpInside)

        let dateStack = UIStackView(arrangedSubviews: [pickersRow, applyButton])
        dateStack.axis = .vertical
        dateStack.spacing = Constants.UI.smallPadding
        dateStack.alignment = .fill
        dateStack.layoutMargins = UIEdgeInsets(
            top: Constants.UI.smallPadding,
            left: Constants.UI.standardPadding,
            bottom: Constants.UI.smallPadding,
            right: Constants.UI.standardPadding
        )
        dateStack.isLayoutMarginsRelativeArrangement = true
        dateRangeContainer.addSubview(dateStack)
        dateStack.pin(to: dateRangeContainer)

        // Header stack: chips + dateRange (collapses when hidden)
        headerStackView.addArrangedSubview(chipScrollView)
        headerStackView.addArrangedSubview(dateRangeContainer)

        updateTableHeader()
    }

    private func updateTableHeader() {
        let fallbackWidth = view.window?.windowScene?.screen.bounds.width ?? view.bounds.width
        let width = tableView.bounds.width > 0 ? tableView.bounds.width : fallbackWidth
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let size = headerStackView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        headerStackView.frame = CGRect(origin: .zero, size: size)
        tableView.tableHeaderView = headerStackView
    }

    // MARK: - Chip helpers

    private func makeChipButton(title: String, tag: Int) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var attrs = incoming
            attrs.font = UIFont.systemFont(ofSize: Constants.Font.subtitle, weight: .medium)
            return attrs
        }
        config.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.UI.chipPaddingVertical,
            leading: Constants.UI.chipPaddingHorizontal,
            bottom: Constants.UI.chipPaddingVertical,
            trailing: Constants.UI.chipPaddingHorizontal
        )
        config.cornerStyle = .capsule

        let button = UIButton(configuration: config)
        button.tag = tag
        button.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        return button
    }

    private func updateChipSelection() {
        let allFilters: [DateFilter] = DateFilter.presets + [.custom(from: Date(), to: Date())]
        for (i, button) in chipButtons.enumerated() {
            let isSelected: Bool
            switch (selectedFilter, allFilters[i]) {
            case (.all, .all), (.today, .today), (.week, .week), (.month, .month):
                isSelected = true
            case (.custom, .custom):
                isSelected = true
            default:
                isSelected = false
            }

            button.configuration?.baseBackgroundColor = isSelected ? .systemBlue : .secondarySystemBackground
            button.configuration?.baseForegroundColor = isSelected ? .white : .label
        }
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        router?.navigateToCreate()
    }

    @objc private func chipTapped(_ sender: UIButton) {
        let presets = DateFilter.presets
        if sender.tag < presets.count {
            selectedFilter = presets[sender.tag]
            dateRangeContainer.isHidden = true
        } else {
            selectedFilter = .custom(from: fromPicker.date, to: toPicker.date)
            dateRangeContainer.isHidden = false
        }
        updateChipSelection()
        updateTableHeader()
        interactor?.applyFilter(selectedFilter)
    }

    @objc private func applyDateRange() {
        selectedFilter = .custom(from: fromPicker.date, to: toPicker.date)
        interactor?.applyFilter(selectedFilter)
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
        let section = operationSections[section - 1]
        return "\(section.categoryIcon) \(section.categoryName)"
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

        let section = operationSections[section - 1]

        let header = UIView()
        header.backgroundColor = .clear

        let iconView = UIImageView(image: UIImage(systemName: section.categoryIcon))
        iconView.tintColor = .label
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = section.categoryName
        label.font = .systemFont(ofSize: Constants.Font.title, weight: .semibold)

        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = Constants.UI.smallPadding
        stack.alignment = .center

        header.addSubview(stack)
        stack.pinLeft(to: header, Constants.UI.standardPadding)
        stack.pinCenterY(to: header)
        iconView.setWidth(Constants.UI.iconSizeMedium)
        iconView.setHeight(Constants.UI.iconSizeMedium)

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
