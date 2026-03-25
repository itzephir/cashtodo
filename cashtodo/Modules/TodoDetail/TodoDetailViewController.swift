import UIKit

final class TodoDetailViewController: UIViewController, TodoDetailDisplayLogic {

    // MARK: - VIPER references

    var interactor: (TodoDetailBusinessLogic & TodoDetailDataStore)?
    var router: TodoDetailRoutingLogic?

    // MARK: - State

    private var isEditingMode = false {
        didSet { updateEditingState() }
    }

    private var isNewTodo: Bool {
        interactor?.todoId == nil
    }

    // MARK: - UI Elements

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.UI.standardPadding
        return stackView
    }()

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = L10n.labelName
        textField.font = .systemFont(ofSize: Constants.Font.title)
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .next
        return textField
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.labelDescription
        label.font = .systemFont(ofSize: Constants.Font.subtitle, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: Constants.Font.title)
        textView.layer.borderColor = UIColor.separator.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = Constants.UI.smallCornerRadius
        textView.textContainerInset = UIEdgeInsets(
            top: Constants.UI.smallPadding,
            left: Constants.UI.smallPadding,
            bottom: Constants.UI.smallPadding,
            right: Constants.UI.smallPadding
        )
        textView.isScrollEnabled = false
        return textView
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.labelPrice
        label.font = .systemFont(ofSize: Constants.Font.subtitle, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let priceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = L10n.placeholderPrice
        textField.font = .systemFont(ofSize: Constants.Font.price)
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let operationsHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.labelLinkedOps
        label.font = .systemFont(ofSize: Constants.Font.title, weight: .semibold)
        return label
    }()

    private let operationsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.UI.smallPadding
        return stackView
    }()

    private let emptyOperationsLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.emptyLinkedOps
        label.font = .systemFont(ofSize: Constants.Font.subtitle)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        return label
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.buttonDelete, for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.Font.title, weight: .medium)
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = Constants.UI.cornerRadius
        return button
    }()

    private let decimalDelegate = DecimalTextFieldDelegate()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        priceTextField.delegate = decimalDelegate
        setupLayout()
        setupActions()
        interactor?.loadTodo()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        scrollView.pinLeft(to: view.leadingAnchor)
        scrollView.pinRight(to: view.trailingAnchor)
        scrollView.pinBottom(to: view.bottomAnchor)

        scrollView.addSubview(contentStackView)
        contentStackView.pinTop(to: scrollView.contentLayoutGuide.topAnchor, Constants.UI.standardPadding)
        contentStackView.pinBottom(to: scrollView.contentLayoutGuide.bottomAnchor, Constants.UI.standardPadding)
        contentStackView.pinLeft(to: scrollView.frameLayoutGuide.leadingAnchor, Constants.UI.standardPadding)
        contentStackView.pinRight(to: scrollView.frameLayoutGuide.trailingAnchor, Constants.UI.standardPadding)

        contentStackView.addArrangedSubview(titleTextField)

        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(descriptionTextView)
        descriptionTextView.setHeight(mode: .grOE, Constants.UI.descriptionMinHeight)

        contentStackView.addArrangedSubview(priceLabel)
        contentStackView.addArrangedSubview(priceTextField)

        contentStackView.addArrangedSubview(operationsHeaderLabel)
        contentStackView.addArrangedSubview(operationsStackView)
        contentStackView.addArrangedSubview(emptyOperationsLabel)

        let spacer = UIView()
        contentStackView.addArrangedSubview(spacer)
        spacer.setHeight(mode: .grOE, Constants.UI.standardPadding)

        contentStackView.addArrangedSubview(deleteButton)
        deleteButton.setHeight(Constants.UI.buttonHeight)
    }

    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    // MARK: - Navigation bar

    private func updateEditingState() {
        titleTextField.isEnabled = isEditingMode
        descriptionTextView.isEditable = isEditingMode
        priceTextField.isEnabled = isEditingMode

        descriptionTextView.layer.borderColor = isEditingMode
            ? UIColor.separator.cgColor
            : UIColor.clear.cgColor

        if isEditingMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: L10n.buttonSave,
                style: .prominent,
                target: self,
                action: #selector(saveButtonTapped)
            )
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(cancelButtonTapped)
            )
            deleteButton.isHidden = true
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: Constants.Icon.edit),
                style: .plain,
                target: self,
                action: #selector(editButtonTapped)
            )
            navigationItem.leftBarButtonItem = nil
            deleteButton.isHidden = isNewTodo
        }
    }

    // MARK: - Actions

    @objc private func editButtonTapped() {
        isEditingMode = true
    }

    @objc private func saveButtonTapped() {
        let title = titleTextField.text ?? ""
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            displayError(L10n.errorEmptyTitle)
            return
        }
        let descriptionText = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let priceText = priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        interactor?.saveTodo(
            title: title,
            descriptionText: descriptionText?.isEmpty == true ? nil : descriptionText,
            priceText: priceText?.isEmpty == true ? nil : priceText
        )
    }

    @objc private func cancelButtonTapped() {
        if isNewTodo {
            router?.dismiss()
        } else {
            isEditingMode = false
            interactor?.loadTodo()
        }
    }

    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: L10n.alertDeleteTask,
            message: L10n.alertCannotUndo,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.buttonCancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.buttonDelete, style: .destructive) { [weak self] _ in
            self?.interactor?.deleteTodo()
        })
        present(alert, animated: true)
    }

    // MARK: - TodoDetailDisplayLogic

    func displayTodo(_ viewModel: TodoDetailViewModel) {
        titleTextField.text = viewModel.title
        descriptionTextView.text = viewModel.descriptionText
        priceTextField.text = viewModel.priceText

        isEditingMode = false
        deleteButton.isHidden = false

        configureOperations(viewModel.linkedOperations)
    }

    func displayNewTodoForm() {
        titleTextField.text = ""
        descriptionTextView.text = ""
        priceTextField.text = ""
        title = L10n.todoNew

        operationsHeaderLabel.isHidden = true
        operationsStackView.isHidden = true
        emptyOperationsLabel.isHidden = true
        deleteButton.isHidden = true

        isEditingMode = true
    }

    func displaySaveSuccess() {
        router?.dismiss()
    }

    func displayDeleteSuccess() {
        router?.dismiss()
    }

    func displayError(_ message: String) {
        let alert = UIAlertController(
            title: L10n.errorTitle,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.buttonOK, style: .default))
        present(alert, animated: true)
    }

    // MARK: - Operations list

    private func configureOperations(_ operations: [LinkedOperationViewModel]) {
        operationsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if operations.isEmpty {
            operationsStackView.isHidden = true
            emptyOperationsLabel.isHidden = false
        } else {
            operationsStackView.isHidden = false
            emptyOperationsLabel.isHidden = true

            for operation in operations {
                let row = makeOperationRow(operation)
                operationsStackView.addArrangedSubview(row)
            }
        }
    }

    private func makeOperationRow(_ operation: LinkedOperationViewModel) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = Constants.UI.smallCornerRadius
        container.backgroundColor = .secondarySystemBackground

        let iconImageView = UIImageView(image: UIImage(systemName: operation.categoryIcon))
        iconImageView.tintColor = .label
        iconImageView.contentMode = .scaleAspectFit
        container.addSubview(iconImageView)
        iconImageView.pinLeft(to: container.leadingAnchor, Constants.UI.smallPadding)
        iconImageView.pinCenterY(to: container)
        iconImageView.setWidth(Constants.UI.iconSize)
        iconImageView.setHeight(Constants.UI.iconSize)

        let titleLabel = UILabel()
        titleLabel.text = operation.title
        titleLabel.font = .systemFont(ofSize: Constants.Font.title)
        container.addSubview(titleLabel)
        titleLabel.pinLeft(to: iconImageView.trailingAnchor, Constants.UI.smallPadding)
        titleLabel.pinCenterY(to: container)

        let amountLabel = UILabel()
        amountLabel.text = operation.amountText
        amountLabel.font = .systemFont(ofSize: Constants.Font.price, weight: .medium)
        amountLabel.textColor = .secondaryLabel
        container.addSubview(amountLabel)
        amountLabel.pinRight(to: container.trailingAnchor, Constants.UI.smallPadding)
        amountLabel.pinCenterY(to: container)
        titleLabel.pinRight(to: amountLabel.leadingAnchor, Constants.UI.smallPadding, .lsOE)

        container.setHeight(Constants.UI.cellHeight)

        return container
    }
}
