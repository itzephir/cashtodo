import UIKit

final class OperationEditViewController: UIViewController {

    // MARK: - VIPER

    var interactor: OperationEditBusinessLogic?
    var router: OperationEditRoutingLogic?

    // MARK: - Data

    private var categories: [CategoryPickerItem] = []
    private var todos: [TodoPickerItem] = []

    private let decimalDelegate = DecimalTextFieldDelegate()

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleTextField: UITextField = {
        let field = UITextField()
        field.placeholder = L10n.labelName
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: Constants.Font.title)
        return field
    }()

    private let amountTextField: UITextField = {
        let field = UITextField()
        field.placeholder = L10n.labelAmount
        field.borderStyle = .roundedRect
        field.keyboardType = .decimalPad
        field.font = .systemFont(ofSize: Constants.Font.title)
        return field
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        return picker
    }()

    private let categoryPicker = UIPickerView()
    private let todoPicker = UIPickerView()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.labelDate
        label.font = .systemFont(ofSize: Constants.Font.subtitle)
        label.textColor = .secondaryLabel
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.labelCategory
        label.font = .systemFont(ofSize: Constants.Font.subtitle)
        label.textColor = .secondaryLabel
        return label
    }()

    private let todoLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.labelLinkedTask
        label.font = .systemFont(ofSize: Constants.Font.subtitle)
        label.textColor = .secondaryLabel
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        amountTextField.delegate = decimalDelegate
        configureNavigationBar()
        configurePickers()
        setupLayout()
        interactor?.loadData()
    }

    // MARK: - Configuration

    private func configureNavigationBar() {
        navigationItem.title = L10n.operationTitle

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
    }

    private func configurePickers() {
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        todoPicker.delegate = self
        todoPicker.dataSource = self
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.pin(to: view)

        scrollView.addSubview(contentView)
        contentView.pinTop(to: scrollView.contentLayoutGuide.topAnchor)
        contentView.pinBottom(to: scrollView.contentLayoutGuide.bottomAnchor)
        contentView.pinLeft(to: scrollView.contentLayoutGuide.leadingAnchor)
        contentView.pinRight(to: scrollView.contentLayoutGuide.trailingAnchor)
        contentView.pinWidth(to: scrollView.frameLayoutGuide.widthAnchor)

        let padding = Constants.UI.standardPadding
        let smallPadding = Constants.UI.smallPadding
        let pickerHeight: Double = 120

        contentView.addSubview(titleTextField)
        titleTextField.pinTop(to: contentView, Constants.UI.largePadding)
        titleTextField.pinLeft(to: contentView, padding)
        titleTextField.pinRight(to: contentView, padding)

        contentView.addSubview(amountTextField)
        amountTextField.pinTop(to: titleTextField.bottomAnchor, padding)
        amountTextField.pinLeft(to: contentView, padding)
        amountTextField.pinRight(to: contentView, padding)

        contentView.addSubview(dateLabel)
        dateLabel.pinTop(to: amountTextField.bottomAnchor, padding)
        dateLabel.pinLeft(to: contentView, padding)

        contentView.addSubview(datePicker)
        datePicker.pinCenterY(to: dateLabel)
        datePicker.pinRight(to: contentView, padding)

        contentView.addSubview(categoryLabel)
        categoryLabel.pinTop(to: dateLabel.bottomAnchor, padding)
        categoryLabel.pinLeft(to: contentView, padding)

        contentView.addSubview(categoryPicker)
        categoryPicker.pinTop(to: categoryLabel.bottomAnchor, smallPadding)
        categoryPicker.pinLeft(to: contentView, padding)
        categoryPicker.pinRight(to: contentView, padding)
        categoryPicker.setHeight(pickerHeight)

        contentView.addSubview(todoLabel)
        todoLabel.pinTop(to: categoryPicker.bottomAnchor, padding)
        todoLabel.pinLeft(to: contentView, padding)

        contentView.addSubview(todoPicker)
        todoPicker.pinTop(to: todoLabel.bottomAnchor, smallPadding)
        todoPicker.pinLeft(to: contentView, padding)
        todoPicker.pinRight(to: contentView, padding)
        todoPicker.setHeight(pickerHeight)
        todoPicker.pinBottom(to: contentView, Constants.UI.largePadding)
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        router?.dismiss()
    }

    @objc private func saveTapped() {
        let selectedCategoryIndex = categoryPicker.selectedRow(inComponent: 0)
        let selectedTodoRow = todoPicker.selectedRow(inComponent: 0)
        let todoIndex: Int? = selectedTodoRow > 0 ? selectedTodoRow - 1 : nil

        interactor?.saveOperation(
            title: titleTextField.text ?? "",
            amountText: amountTextField.text ?? "",
            date: datePicker.date,
            categoryIndex: selectedCategoryIndex,
            todoIndex: todoIndex
        )
    }
}

// MARK: - OperationEditDisplayLogic

extension OperationEditViewController: OperationEditDisplayLogic {
    func displayCategories(_ categories: [CategoryPickerItem]) {
        self.categories = categories
        categoryPicker.reloadAllComponents()
    }

    func displayTodos(_ todos: [TodoPickerItem]) {
        self.todos = todos
        todoPicker.reloadAllComponents()
    }

    func displayOperationData(_ viewModel: OperationEditViewModel) {
        titleTextField.text = viewModel.title
        amountTextField.text = viewModel.amountText
        datePicker.date = viewModel.date

        if viewModel.selectedCategoryIndex < categories.count {
            categoryPicker.selectRow(viewModel.selectedCategoryIndex, inComponent: 0, animated: false)
        }

        if let todoIdx = viewModel.selectedTodoIndex, todoIdx < todos.count {
            todoPicker.selectRow(todoIdx + 1, inComponent: 0, animated: false)
        } else {
            todoPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }

    func displayValidationError(_ message: String) {
        let alert = UIAlertController(
            title: L10n.errorTitle,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.buttonOK, style: .default))
        present(alert, animated: true)
    }

    func displaySaveSuccess() {
        router?.dismiss()
    }
}

// MARK: - UIPickerViewDataSource

extension OperationEditViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === categoryPicker {
            return categories.count
        }
        return todos.count + 1
    }
}

// MARK: - UIPickerViewDelegate

extension OperationEditViewController: UIPickerViewDelegate {
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        if pickerView === categoryPicker {
            guard row < categories.count else { return nil }
            return categories[row].name
        }
        if row == 0 {
            return L10n.labelNone
        }
        let todoIndex = row - 1
        guard todoIndex < todos.count else { return nil }
        return todos[todoIndex].title
    }
}
